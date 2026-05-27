"""
Tropical Spectral Certificates — Real-World Applications

Demonstrates practical applications of tropical spectral gap theory:
1. ReLU network curvature certification
2. Adversarial robustness lower bounds
3. Energy landscape analysis
4. Trust-region optimization
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Self-contained algorithm implementations
# ============================================================

def tropical_spectral_gap(Q: np.ndarray) -> float:
    """Compute Gershgorin diagonal dominance margin."""
    n = Q.shape[0]
    return min(Q[i, i] - sum(abs(Q[i, j]) for j in range(n) if j != i) for i in range(n))


def certified_radius_from_gap(gamma: float, R: float, rho: float) -> float:
    """Certified radius from gap, remainder, and localization."""
    if gamma <= 0 or R <= 0:
        return rho if gamma > 0 else 0.0
    return min(np.sqrt(gamma / (2 * R)), rho)


# ============================================================
# Application 1: ReLU Network Curvature Surrogate
# ============================================================

def relu_network_curvature_surrogate(
    W1: np.ndarray, W2: np.ndarray, x: np.ndarray, activation_pattern: np.ndarray
) -> np.ndarray:
    """Compute the Hessian surrogate for a 2-layer ReLU network.

    For a 2-layer ReLU network f(x) = W2 @ relu(W1 @ x), in a fixed
    activation region (where relu is linear), the function is affine:
    f(x) = W2 @ diag(activation_pattern) @ W1 @ x + bias

    The Hessian is zero, but the *loss Hessian* (for squared loss) is:
    H = J^T J where J = W2 @ diag(activation_pattern) @ W1

    This surrogate captures the local curvature of the loss landscape.

    Args:
        W1: First layer weights (hidden × input).
        W2: Second layer weights (output × hidden).
        x: Input point.
        activation_pattern: Binary mask for active ReLU units.

    Returns:
        Curvature surrogate matrix (input_dim × input_dim).
    """
    D = np.diag(activation_pattern)
    J = W2 @ D @ W1  # Jacobian in this activation region
    H = J.T @ J  # Gauss-Newton curvature
    return H


def certify_relu_point(
    W1: np.ndarray, W2: np.ndarray, x: np.ndarray,
    R: float = 0.1, rho: float = 5.0
) -> dict:
    """Certify robustness at a point for a 2-layer ReLU network.

    Args:
        W1, W2: Network weights.
        x: Input point.
        R: Remainder bound.
        rho: Localization radius.

    Returns:
        Dictionary with certification results.
    """
    # Determine activation pattern
    pre_activation = W1 @ x
    activation = (pre_activation > 0).astype(float)

    # Compute curvature surrogate
    Q = relu_network_curvature_surrogate(W1, W2, x, activation)

    # Tropical certificate
    gamma = tropical_spectral_gap(Q)
    r_cert = certified_radius_from_gap(gamma, R, rho)

    # Classical eigenvalue certificate
    eigvals = np.linalg.eigvalsh(Q)
    lambda_min = float(eigvals.min())
    r_eig = certified_radius_from_gap(lambda_min, R, rho)

    return {
        'activation_pattern': activation,
        'curvature_matrix': Q,
        'tropical_gap': gamma,
        'min_eigenvalue': lambda_min,
        'r_tropical': r_cert,
        'r_eigenvalue': r_eig,
        'active_neurons': int(activation.sum()),
    }


# ============================================================
# Application 2: Adversarial Robustness Bounds
# ============================================================

def batch_certify(
    Q_matrices: List[np.ndarray],
    R: float,
    rho: float,
) -> dict:
    """Certify robustness for a batch of points.

    Args:
        Q_matrices: List of curvature surrogate matrices.
        R: Remainder bound.
        rho: Localization radius.

    Returns:
        Batch certification statistics.
    """
    tropical_radii = []
    eigenvalue_radii = []
    gaps = []

    for Q in Q_matrices:
        gamma = tropical_spectral_gap(Q)
        gaps.append(gamma)

        r_trop = certified_radius_from_gap(gamma, R, rho)
        tropical_radii.append(r_trop)

        eigvals = np.linalg.eigvalsh(Q)
        lam_min = float(eigvals.min())
        r_eig = certified_radius_from_gap(lam_min, R, rho)
        eigenvalue_radii.append(r_eig)

    return {
        'tropical_radii': np.array(tropical_radii),
        'eigenvalue_radii': np.array(eigenvalue_radii),
        'gaps': np.array(gaps),
        'mean_tropical': np.mean(tropical_radii),
        'mean_eigenvalue': np.mean(eigenvalue_radii),
        'certified_fraction_tropical': np.mean(np.array(tropical_radii) > 0),
        'certified_fraction_eigenvalue': np.mean(np.array(eigenvalue_radii) > 0),
    }


# ============================================================
# Application 3: Energy Landscape Analysis
# ============================================================

def analyze_energy_landscape(
    Q: np.ndarray,
    R: float,
    r_max: float = 3.0,
    n_points: int = 100,
) -> dict:
    """Analyze energy barriers from tropical spectral gap.

    Args:
        Q: Curvature matrix at a critical point.
        R: Remainder bound.
        r_max: Maximum radius to analyze.
        n_points: Number of radius points.

    Returns:
        Energy landscape analysis results.
    """
    gamma = tropical_spectral_gap(Q)
    alpha = max(gamma, 0)

    radii = np.linspace(0, r_max, n_points)
    barriers = np.maximum(0, (alpha / 2) * radii**2 - R * radii**4)
    guaranteed = (alpha / 4) * radii**2
    valid = R * radii**2 <= alpha / 4

    # Critical radius where barrier vanishes
    if R > 0 and alpha > 0:
        r_critical = np.sqrt(alpha / (2 * R))
    else:
        r_critical = float('inf')

    return {
        'radii': radii,
        'barriers': barriers,
        'guaranteed': guaranteed,
        'valid_region': valid,
        'gamma': gamma,
        'alpha': alpha,
        'r_critical': r_critical,
    }


# ============================================================
# Application 4: Trust-Region Optimization
# ============================================================

def trust_region_subproblem(
    Q: np.ndarray,
    g: np.ndarray,
    delta: float,
) -> dict:
    """Analyze trust-region subproblem with tropical certificates.

    For the trust-region subproblem:
      min g^T h + (1/2) h^T Q h  s.t. ||h|| <= delta

    The tropical spectral gap provides a lower bound on the model
    improvement.

    Args:
        Q: Hessian approximation.
        g: Gradient.
        delta: Trust-region radius.

    Returns:
        Analysis of the trust-region subproblem.
    """
    gamma = tropical_spectral_gap(Q)
    G = float(np.linalg.norm(g))
    alpha = max(gamma, 0)

    # Margin bound from theorem
    if alpha > 0:
        margin = -G**2 / (2 * alpha)
        optimal_s = G / alpha
    else:
        margin = float('-inf')
        optimal_s = float('inf')

    # Actual solution (approximate by gradient method)
    if alpha > 0 and G > 0:
        # Cauchy point: h = -(g^Tg / g^TQg) * g
        gQg = float(g @ Q @ g)
        if gQg > 0:
            t = min(G**2 / gQg, delta / G)
            h_cauchy = -t * g
            model_decrease = float(g @ h_cauchy + 0.5 * h_cauchy @ Q @ h_cauchy)
        else:
            h_cauchy = -delta * g / G
            model_decrease = float(g @ h_cauchy + 0.5 * h_cauchy @ Q @ h_cauchy)
    else:
        h_cauchy = np.zeros_like(g)
        model_decrease = 0.0

    return {
        'gamma': gamma,
        'gradient_norm': G,
        'margin_bound': margin,
        'optimal_s': optimal_s,
        'cauchy_decrease': model_decrease,
        'cauchy_norm': float(np.linalg.norm(h_cauchy)),
    }


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 60)
    print("APPLICATION 1: ReLU Network Certification")
    print("=" * 60)

    # Create a small 2-layer ReLU network
    input_dim = 5
    hidden_dim = 10
    output_dim = 1

    W1 = np.random.randn(hidden_dim, input_dim) * 0.5
    W2 = np.random.randn(output_dim, hidden_dim) * 0.3

    # Certify several input points
    print(f"\nNetwork: {input_dim} → {hidden_dim} → {output_dim}")
    print(f"{'Point':>6} {'Active':>8} {'γ':>8} {'λ_min':>8} {'r_trop':>8} {'r_eig':>8}")

    for i in range(5):
        x = np.random.randn(input_dim)
        result = certify_relu_point(W1, W2, x, R=0.1, rho=5.0)
        print(f"{i+1:>6} {result['active_neurons']:>8} "
              f"{result['tropical_gap']:>8.3f} {result['min_eigenvalue']:>8.3f} "
              f"{result['r_tropical']:>8.4f} {result['r_eigenvalue']:>8.4f}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Batch Adversarial Certification")
    print("=" * 60)

    n_batch = 100
    Q_batch = []
    for i in range(n_batch):
        gap = np.random.exponential(2.0)
        n = 8
        Q = np.random.randn(n, n) * 0.3
        Q = (Q + Q.T) / 2
        for j in range(n):
            off_sum = sum(abs(Q[j, k]) for k in range(n) if k != j)
            Q[j, j] = off_sum + gap
        Q_batch.append(Q)

    stats = batch_certify(Q_batch, R=0.2, rho=5.0)
    print(f"\nBatch of {n_batch} points:")
    print(f"  Mean tropical radius:     {stats['mean_tropical']:.4f}")
    print(f"  Mean eigenvalue radius:   {stats['mean_eigenvalue']:.4f}")
    print(f"  Certified (tropical):     {stats['certified_fraction_tropical']*100:.1f}%")
    print(f"  Certified (eigenvalue):   {stats['certified_fraction_eigenvalue']*100:.1f}%")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Energy Landscape Analysis")
    print("=" * 60)

    Q = np.array([
        [5.0, 1.0, -0.5],
        [1.0, 4.0, 0.3],
        [-0.5, 0.3, 6.0],
    ])
    landscape = analyze_energy_landscape(Q, R=0.1)
    print(f"\nCurvature matrix tropical gap: γ = {landscape['gamma']:.4f}")
    print(f"Critical radius: r_c = {landscape['r_critical']:.4f}")
    print(f"Barrier at r=1: {landscape['barriers'][33]:.4f}")

    print("\n" + "=" * 60)
    print("APPLICATION 4: Trust-Region Analysis")
    print("=" * 60)

    Q = np.array([
        [5.0, 1.0, -0.5],
        [1.0, 4.0, 0.3],
        [-0.5, 0.3, 6.0],
    ])
    g = np.array([1.0, -0.5, 0.3])

    for delta in [0.5, 1.0, 2.0, 5.0]:
        result = trust_region_subproblem(Q, g, delta)
        print(f"\nΔ = {delta:.1f}:")
        print(f"  Tropical gap:    γ = {result['gamma']:.4f}")
        print(f"  Margin bound:    {result['margin_bound']:.4f}")
        print(f"  Cauchy decrease: {result['cauchy_decrease']:.4f}")


"""
Tropical Spectral Certificates — Interactive Demonstration

Demonstrates the core theorems with concrete numerical examples:
1. Computing tropical spectral gaps
2. Certified robustness radii vs. classical eigenvalue methods
3. Energy barrier computations
4. Trust-region margin bounds
5. Comparison with Lipschitz baselines
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ============================================================
# Core Algorithm Implementations (self-contained)
# ============================================================

def tropical_spectral_gap(Q):
    """Compute Gershgorin diagonal dominance margin."""
    n = Q.shape[0]
    gaps = []
    for i in range(n):
        off_diag_sum = sum(abs(Q[i, j]) for j in range(n) if j != i)
        gaps.append(Q[i, i] - off_diag_sum)
    return min(gaps)


def certified_robust_radius(Q, R, rho, use_eigenvalue=False):
    """Certified radius from tropical gap."""
    gamma = tropical_spectral_gap(Q)
    info = {'gamma': gamma, 'alpha': gamma}

    if gamma <= 0:
        r_trop = 0.0
    elif R > 0:
        r_trop = min(np.sqrt(gamma / (2 * R)), rho)
    else:
        r_trop = rho
    info['r_tropical'] = r_trop

    if use_eigenvalue:
        eigvals = np.linalg.eigvalsh(Q)
        alpha_eig = float(eigvals.min())
        info['alpha_eigenvalue'] = alpha_eig
        if alpha_eig > 0 and R > 0:
            info['r_eigenvalue'] = min(np.sqrt(alpha_eig / (2 * R)), rho)
        elif alpha_eig > 0:
            info['r_eigenvalue'] = rho
        else:
            info['r_eigenvalue'] = 0.0

    return r_trop, info


def generate_diag_dominant_matrix(n, gap, off_diag_scale=1.0, seed=42):
    """Generate symmetric diag-dominant matrix with given gap."""
    rng = np.random.RandomState(seed)
    Q = off_diag_scale * rng.randn(n, n)
    Q = (Q + Q.T) / 2
    for i in range(n):
        off_sum = sum(abs(Q[i, j]) for j in range(n) if j != i)
        Q[i, i] = off_sum + gap
    return Q


def lipschitz_radius(L, margin):
    """Lipschitz baseline: r = margin / L."""
    if L <= 0:
        return float('inf') if margin > 0 else 0.0
    return max(0.0, margin / L)


# ============================================================
# Demo 1: Basic Tropical Gap Computation
# ============================================================
print("=" * 60)
print("DEMO 1: Tropical Spectral Gap Computation")
print("=" * 60)

Q_examples = [
    ("Identity (2×2)", np.eye(2)),
    ("Diagonal dominant", np.array([[5.0, 1.0], [1.0, 4.0]])),
    ("Nearly singular", np.array([[2.0, 1.9], [1.9, 2.0]])),
    ("Negative off-diagonal", np.array([[3.0, -1.0], [-1.0, 3.0]])),
]

for name, Q in Q_examples:
    gamma = tropical_spectral_gap(Q)
    eigvals = np.linalg.eigvalsh(Q)
    print(f"\n{name}:")
    print(f"  Matrix: {Q.tolist()}")
    print(f"  Tropical gap γ = {gamma:.4f}")
    print(f"  Min eigenvalue  = {eigvals.min():.4f}")
    print(f"  Gap ≤ min eigenvalue: {gamma <= eigvals.min() + 1e-10}")


# ============================================================
# Demo 2: Certified Radii — Tropical vs. Eigenvalue
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Certified Robustness Radii")
print("=" * 60)

dims = [3, 5, 10, 20, 50]
gaps = [1.0, 2.0, 5.0]
R_val = 0.5
rho_val = 10.0

print(f"\nRemainder bound R = {R_val}, Localization radius ρ = {rho_val}")
print(f"{'Dim':>5} {'Gap':>5} {'r_trop':>10} {'r_eig':>10} {'ratio':>10}")
print("-" * 45)

for n in dims:
    for gap in gaps:
        Q = generate_diag_dominant_matrix(n, gap, seed=42)
        r_trop, info = certified_robust_radius(Q, R_val, rho_val, use_eigenvalue=True)
        r_eig = info.get('r_eigenvalue', 0)
        ratio = r_trop / r_eig if r_eig > 0 else float('inf')
        print(f"{n:>5} {gap:>5.1f} {r_trop:>10.4f} {r_eig:>10.4f} {ratio:>10.4f}")


# ============================================================
# Demo 3: Energy Barrier Heights
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Energy Barrier Heights")
print("=" * 60)

Q = generate_diag_dominant_matrix(5, gap=3.0, seed=42)
gamma = tropical_spectral_gap(Q)
R_val = 0.2
print(f"\n5×5 matrix with tropical gap γ = {gamma:.4f}")
print(f"Remainder bound R = {R_val}")
print(f"\n{'Radius r':>10} {'Barrier (α/4)r²':>18} {'Condition R·r²≤α/4':>20}")

for r in [0.5, 1.0, 1.5, 2.0, 2.5]:
    cond = R_val * r**2 <= gamma / 4
    barrier = (gamma / 4) * r**2 if cond else max(0, (gamma/2)*r**2 - R_val*r**4)
    print(f"{r:>10.2f} {barrier:>18.4f} {'✓' if cond else '✗':>20}")


# ============================================================
# Demo 4: Trust-Region Margin
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Trust-Region Margin Bounds")
print("=" * 60)

alphas = [1.0, 2.0, 5.0, 10.0]
G_val = 2.0
print(f"\nGradient norm bound G = {G_val}")
print(f"{'α':>8} {'Margin -G²/(2α)':>18} {'Optimal s*':>12}")
for alpha in alphas:
    margin = -G_val**2 / (2 * alpha)
    s_star = G_val / alpha
    print(f"{alpha:>8.1f} {margin:>18.4f} {s_star:>12.4f}")


# ============================================================
# Demo 5: Comparison with Lipschitz Baseline
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Tropical vs. Lipschitz Certificates")
print("=" * 60)

np.random.seed(123)
n_points = 50
n_dim = 10
results_trop = []
results_lip = []
results_eig = []

for i in range(n_points):
    gap = np.random.uniform(0.5, 5.0)
    Q = generate_diag_dominant_matrix(n_dim, gap, off_diag_scale=0.5, seed=i)
    R_val = np.random.uniform(0.1, 1.0)
    rho_val = 10.0

    # Tropical certificate
    r_trop, info = certified_robust_radius(Q, R_val, rho_val, use_eigenvalue=True)
    results_trop.append(r_trop)
    results_eig.append(info.get('r_eigenvalue', 0))

    # Lipschitz baseline (using spectral norm as Lipschitz constant)
    L = np.linalg.norm(Q, ord=2)
    margin = gap  # use gap as proxy margin
    r_lip = lipschitz_radius(L, margin)
    results_lip.append(r_lip)

results_trop = np.array(results_trop)
results_lip = np.array(results_lip)
results_eig = np.array(results_eig)

print(f"\nOver {n_points} random test cases:")
print(f"  Mean tropical radius:   {results_trop.mean():.4f}")
print(f"  Mean eigenvalue radius: {results_eig.mean():.4f}")
print(f"  Mean Lipschitz radius:  {results_lip.mean():.4f}")
print(f"  Tropical/Eigenvalue ratio: {(results_trop / np.maximum(results_eig, 1e-10)).mean():.4f}")
print(f"  Tropical/Lipschitz ratio:  {(results_trop / np.maximum(results_lip, 1e-10)).mean():.4f}")


# ============================================================
# Demo 6: Visualization
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Generating Visualizations")
print("=" * 60)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Plot 1: Gap vs. Certified Radius
gaps_range = np.linspace(0.1, 10.0, 100)
R_fixed = 0.5
radii_trop = np.sqrt(gaps_range / (2 * R_fixed))

axes[0, 0].plot(gaps_range, radii_trop, 'b-', linewidth=2, label='Tropical')
axes[0, 0].set_xlabel('Tropical Spectral Gap γ')
axes[0, 0].set_ylabel('Certified Radius r')
axes[0, 0].set_title('Certified Radius vs. Tropical Gap')
axes[0, 0].legend()
axes[0, 0].grid(True, alpha=0.3)

# Plot 2: Energy Barrier
r_range = np.linspace(0, 3, 100)
alpha_val = 4.0
R_val = 0.3
barrier = np.maximum(0, (alpha_val / 2) * r_range**2 - R_val * r_range**4)
quarter_barrier = (alpha_val / 4) * r_range**2
valid = R_val * r_range**2 <= alpha_val / 4

axes[0, 1].plot(r_range, barrier, 'b-', linewidth=2, label='Actual barrier')
axes[0, 1].plot(r_range[valid], quarter_barrier[valid], 'r--', linewidth=2,
                label='Guaranteed (α/4)r²')
axes[0, 1].set_xlabel('Radius r')
axes[0, 1].set_ylabel('Energy Barrier Height')
axes[0, 1].set_title('Energy Barrier Theorem')
axes[0, 1].legend()
axes[0, 1].grid(True, alpha=0.3)

# Plot 3: Tropical vs. Eigenvalue radii
axes[1, 0].scatter(results_eig, results_trop, alpha=0.6, s=40)
max_r = max(results_eig.max(), results_trop.max()) * 1.1
axes[1, 0].plot([0, max_r], [0, max_r], 'k--', alpha=0.3, label='y=x')
axes[1, 0].set_xlabel('Eigenvalue Radius')
axes[1, 0].set_ylabel('Tropical Radius')
axes[1, 0].set_title('Tropical vs. Eigenvalue Certificates')
axes[1, 0].legend()
axes[1, 0].grid(True, alpha=0.3)

# Plot 4: Trust Region Margin
s_range = np.linspace(0, 3, 200)
alpha_vals = [1.0, 2.0, 5.0]
G_val = 2.0

for alpha in alpha_vals:
    model = -G_val * s_range + 0.5 * alpha * s_range**2
    margin = -G_val**2 / (2 * alpha)
    axes[1, 1].plot(s_range, model, linewidth=2, label=f'α={alpha}')
    axes[1, 1].axhline(y=margin, linestyle=':', alpha=0.5)

axes[1, 1].axhline(y=0, color='k', linewidth=0.5)
axes[1, 1].set_xlabel('Step size s')
axes[1, 1].set_ylabel('Model improvement')
axes[1, 1].set_title(f'Trust-Region Model (G={G_val})')
axes[1, 1].legend()
axes[1, 1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_certificates_demo.png', dpi=150, bbox_inches='tight')
print("Saved visualization to tropical_certificates_demo.png")

print("\n" + "=" * 60)
print("ALL DEMOS COMPLETE")
print("=" * 60)


"""Generate PACKAGE.json from the deliverable files."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all source files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Catalog/Pythagorean/TropicalSpectralCertificates.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_gap = read_file('viz_tropical_gap.py')
viz_trust = read_file('viz_trust_region.py')
viz_heatmap = read_file('viz_heatmap.py')

package = {
    "title": "Tropical Spectral Certificates for Neural Network Robustness",
    "domain": "Pythagorean / Tropical Geometry / Machine Learning",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Spectral Certificates Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Spectral Gap Computation",
            "pseudocode": """ALGORITHM: TropicalSpectralGap
INPUT: Symmetric matrix Q ∈ ℝⁿˣⁿ
OUTPUT: Tropical spectral gap γ

1. For i = 1, ..., n:
     margin[i] ← Q[i,i] - Σ_{j≠i} |Q[i,j]|
2. γ ← min(margin[1], ..., margin[n])
3. Return γ

COMPLEXITY: O(n²) time, O(n) space""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Gap vs Certified Radius",
            "code": viz_gap,
            "description": "Shows certified robustness radius growth with tropical spectral gap, comparison with eigenvalue certificates, and energy barrier theorem visualization."
        },
        {
            "name": "Trust-Region Margin Bounds",
            "code": viz_trust,
            "description": "Visualizes trust-region model improvement curves for different tropical gaps and the worst-case margin bound."
        },
        {
            "name": "Matrix Diagonal Dominance Heatmap",
            "code": viz_heatmap,
            "description": "Heatmap visualization of matrices with different tropical spectral gaps, showing the relationship between diagonal dominance structure and spectral properties."
        }
    ],
    "interactive_demos": [
        {
            "name": "Tropical Gap Calculator",
            "html": """<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background: #f8f9fa; border-radius: 12px;">
  <h3 style="color: #1a237e; margin-top: 0;">🌴 Tropical Spectral Gap Calculator</h3>
  <p style="color: #555; font-size: 14px;">Enter a 3×3 symmetric matrix to compute its tropical spectral gap and certified radius.</p>

  <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; margin: 16px 0;">
    <input type="number" id="m00" value="5" step="0.1" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; text-align: center; font-size: 16px;">
    <input type="number" id="m01" value="1" step="0.1" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; text-align: center; font-size: 16px;">
    <input type="number" id="m02" value="-0.5" step="0.1" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; text-align: center; font-size: 16px;">
    <input type="number" id="m10" value="1" step="0.1" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; text-align: center; font-size: 16px;" readonly>
    <input type="number" id="m11" value="4" step="0.1" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; text-align: center; font-size: 16px;">
    <input type="number" id="m12" value="0.3" step="0.1" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; text-align: center; font-size: 16px;">
    <input type="number" id="m20" value="-0.5" step="0.1" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; text-align: center; font-size: 16px;" readonly>
    <input type="number" id="m21" value="0.3" step="0.1" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; text-align: center; font-size: 16px;" readonly>
    <input type="number" id="m22" value="6" step="0.1" style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; text-align: center; font-size: 16px;">
  </div>

  <div style="display: flex; gap: 12px; margin: 12px 0;">
    <label style="font-size: 14px; color: #555;">Remainder R: <input type="number" id="R_val" value="0.5" step="0.1" min="0" style="width: 60px; padding: 4px; border: 1px solid #ccc; border-radius: 4px;"></label>
    <label style="font-size: 14px; color: #555;">Radius ρ: <input type="number" id="rho_val" value="10" step="0.5" min="0" style="width: 60px; padding: 4px; border: 1px solid #ccc; border-radius: 4px;"></label>
  </div>

  <button onclick="compute()" style="background: #1a237e; color: white; border: none; padding: 10px 24px; border-radius: 6px; cursor: pointer; font-size: 14px; margin-top: 8px;">Compute Certificate</button>

  <div id="result" style="margin-top: 16px; padding: 16px; background: white; border-radius: 8px; border-left: 4px solid #1a237e; display: none;">
  </div>

  <script>
    // Enforce symmetry
    document.getElementById('m01').addEventListener('input', function() {
      document.getElementById('m10').value = this.value;
    });
    document.getElementById('m02').addEventListener('input', function() {
      document.getElementById('m20').value = this.value;
    });
    document.getElementById('m12').addEventListener('input', function() {
      document.getElementById('m21').value = this.value;
    });

    function compute() {
      const get = id => parseFloat(document.getElementById(id).value) || 0;
      const Q = [
        [get('m00'), get('m01'), get('m02')],
        [get('m01'), get('m11'), get('m12')],
        [get('m02'), get('m12'), get('m22')]
      ];
      const R = get('R_val');
      const rho = get('rho_val');

      // Compute tropical gap
      let gaps = [];
      for (let i = 0; i < 3; i++) {
        let offSum = 0;
        for (let j = 0; j < 3; j++) {
          if (j !== i) offSum += Math.abs(Q[i][j]);
        }
        gaps.push(Q[i][i] - offSum);
      }
      const gamma = Math.min(...gaps);

      // Certified radius
      let r_cert = 0;
      if (gamma > 0 && R > 0) {
        r_cert = Math.min(Math.sqrt(gamma / (2 * R)), rho);
      } else if (gamma > 0) {
        r_cert = rho;
      }

      // Energy barrier
      let barrier = 0;
      if (gamma > 0 && R * r_cert * r_cert <= gamma / 4) {
        barrier = (gamma / 4) * r_cert * r_cert;
      }

      const div = document.getElementById('result');
      div.style.display = 'block';
      div.innerHTML = '<h4 style="margin-top:0;color:#1a237e;">Results</h4>' +
        '<table style="width:100%;font-size:14px;">' +
        '<tr><td>Tropical Gap γ:</td><td style="text-align:right;font-weight:bold;color:' + (gamma > 0 ? '#2e7d32' : '#c62828') + '">' + gamma.toFixed(4) + '</td></tr>' +
        '<tr><td>Row margins:</td><td style="text-align:right">[' + gaps.map(g => g.toFixed(3)).join(', ') + ']</td></tr>' +
        '<tr><td>Certified Radius:</td><td style="text-align:right;font-weight:bold;color:#1565c0">' + r_cert.toFixed(4) + '</td></tr>' +
        '<tr><td>Energy Barrier:</td><td style="text-align:right">' + barrier.toFixed(4) + '</td></tr>' +
        '<tr><td>Status:</td><td style="text-align:right">' + (gamma > 0 ? '✅ Positive definite' : '❌ Not certifiable') + '</td></tr>' +
        '</table>';
    }
    compute();
  </script>
</div>""",
            "description": "Interactive calculator for computing tropical spectral gaps and certified robustness radii from matrix entries."
        },
        {
            "name": "Energy Barrier Explorer",
            "html": """<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background: #f8f9fa; border-radius: 12px;">
  <h3 style="color: #1a237e; margin-top: 0;">⚡ Energy Barrier Explorer</h3>
  <p style="color: #555; font-size: 14px;">Explore how the tropical spectral gap controls energy barriers and metastability.</p>

  <div style="margin: 16px 0;">
    <label style="display: block; margin: 8px 0; font-size: 14px;">
      Coercivity α (from tropical gap): <span id="alpha_display">4.0</span>
      <input type="range" id="alpha_slider" min="0.5" max="10" step="0.1" value="4" style="width: 100%;">
    </label>
    <label style="display: block; margin: 8px 0; font-size: 14px;">
      Remainder R: <span id="R_display">0.3</span>
      <input type="range" id="R_slider" min="0.01" max="2" step="0.01" value="0.3" style="width: 100%;">
    </label>
  </div>

  <canvas id="barrier_canvas" width="560" height="300" style="background: white; border-radius: 8px; border: 1px solid #ddd;"></canvas>

  <div id="barrier_info" style="margin-top: 12px; padding: 12px; background: white; border-radius: 8px; font-size: 14px;"></div>

  <script>
    const canvas = document.getElementById('barrier_canvas');
    const ctx = canvas.getContext('2d');

    function draw() {
      const alpha = parseFloat(document.getElementById('alpha_slider').value);
      const R = parseFloat(document.getElementById('R_slider').value);
      document.getElementById('alpha_display').textContent = alpha.toFixed(1);
      document.getElementById('R_display').textContent = R.toFixed(2);

      const W = canvas.width, H = canvas.height;
      const pad = 50;
      ctx.clearRect(0, 0, W, H);

      const r_max = 4;
      const y_max = Math.max(5, alpha * 2);

      function toX(r) { return pad + (r / r_max) * (W - 2*pad); }
      function toY(y) { return H - pad - (y / y_max) * (H - 2*pad); }

      // Axes
      ctx.strokeStyle = '#999';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(pad, H - pad);
      ctx.lineTo(W - pad, H - pad);
      ctx.moveTo(pad, H - pad);
      ctx.lineTo(pad, pad);
      ctx.stroke();

      ctx.fillStyle = '#555';
      ctx.font = '12px Arial';
      ctx.fillText('Radius r', W/2, H - 5);
      ctx.save();
      ctx.translate(12, H/2);
      ctx.rotate(-Math.PI/2);
      ctx.fillText('Barrier', 0, 0);
      ctx.restore();

      // Actual barrier curve
      ctx.beginPath();
      ctx.strokeStyle = '#1565c0';
      ctx.lineWidth = 2.5;
      for (let i = 0; i <= 200; i++) {
        const r = (i / 200) * r_max;
        const b = Math.max(0, (alpha/2)*r*r - R*r*r*r*r);
        const x = toX(r), y = toY(b);
        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
      }
      ctx.stroke();

      // Guaranteed barrier
      const r_valid = Math.sqrt(alpha / (4 * R));
      ctx.beginPath();
      ctx.strokeStyle = '#c62828';
      ctx.lineWidth = 2;
      ctx.setLineDash([6, 4]);
      for (let i = 0; i <= 200; i++) {
        const r = (i / 200) * Math.min(r_valid, r_max);
        const b = (alpha/4)*r*r;
        const x = toX(r), y = toY(b);
        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
      }
      ctx.stroke();
      ctx.setLineDash([]);

      // Critical radius
      const r_crit = Math.sqrt(alpha / (2 * R));
      if (r_crit < r_max) {
        ctx.beginPath();
        ctx.strokeStyle = '#888';
        ctx.lineWidth = 1;
        ctx.setLineDash([3, 3]);
        ctx.moveTo(toX(r_crit), H - pad);
        ctx.lineTo(toX(r_crit), pad);
        ctx.stroke();
        ctx.setLineDash([]);
        ctx.fillStyle = '#888';
        ctx.fillText('r_crit', toX(r_crit) - 15, H - pad + 15);
      }

      // Legend
      ctx.fillStyle = '#1565c0';
      ctx.fillRect(W - 180, 15, 15, 3);
      ctx.fillStyle = '#333';
      ctx.fillText('Actual barrier', W - 160, 20);
      ctx.fillStyle = '#c62828';
      ctx.fillRect(W - 180, 35, 15, 3);
      ctx.fillStyle = '#333';
      ctx.fillText('Guaranteed (α/4)r²', W - 160, 40);

      // Info
      const info = document.getElementById('barrier_info');
      info.innerHTML = `<b>Critical radius:</b> r_crit = ${r_crit.toFixed(3)} | ` +
        `<b>Max barrier:</b> ${((alpha*alpha)/(16*R)).toFixed(3)} | ` +
        `<b>Certified radius:</b> ${r_crit.toFixed(3)}`;
    }

    document.getElementById('alpha_slider').addEventListener('input', draw);
    document.getElementById('R_slider').addEventListener('input', draw);
    draw();
  </script>
</div>""",
            "description": "Interactive visualization of energy barriers controlled by the tropical spectral gap, showing actual vs guaranteed barrier heights."
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("Generated PACKAGE.json")
print(f"File size: {os.path.getsize('PACKAGE.json')} bytes")


"""
Visualization: Matrix Diagonal Dominance Heatmap

Shows the structure of diagonally dominant matrices and how the tropical
spectral gap relates to the visual pattern of diagonal vs off-diagonal entries.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def tropical_spectral_gap(Q):
    n = Q.shape[0]
    return min(Q[i, i] - sum(abs(Q[i, j]) for j in range(n) if j != i) for i in range(n))


def generate_diag_dominant_matrix(n, gap, seed=42):
    rng = np.random.RandomState(seed)
    Q = 0.5 * rng.randn(n, n)
    Q = (Q + Q.T) / 2
    for i in range(n):
        off_sum = sum(abs(Q[i, j]) for j in range(n) if j != i)
        Q[i, i] = off_sum + gap
    return Q


fig, axes = plt.subplots(2, 3, figsize=(14, 9))

gaps = [0.5, 2.0, 5.0, 0.0, -1.0, 10.0]
titles = ['γ = 0.5 (weak)', 'γ = 2.0 (moderate)', 'γ = 5.0 (strong)',
          'γ ≈ 0 (borderline)', 'γ < 0 (not dominant)', 'γ = 10 (very strong)']

for idx, (gap, title) in enumerate(zip(gaps, titles)):
    ax = axes[idx // 3, idx % 3]
    n = 8

    if gap >= 0:
        Q = generate_diag_dominant_matrix(n, gap, seed=42 + idx)
    else:
        rng = np.random.RandomState(42 + idx)
        Q = 2.0 * rng.randn(n, n)
        Q = (Q + Q.T) / 2
        # Don't enforce diagonal dominance

    actual_gap = tropical_spectral_gap(Q)
    eigvals = np.linalg.eigvalsh(Q)
    lam_min = eigvals.min()

    im = ax.imshow(Q, cmap='RdBu_r', aspect='equal',
                   vmin=-np.abs(Q).max(), vmax=np.abs(Q).max())
    ax.set_title(f'{title}\nγ={actual_gap:.2f}, λ_min={lam_min:.2f}', fontsize=10)
    ax.set_xticks([])
    ax.set_yticks([])

    # Highlight diagonal
    for i in range(n):
        ax.add_patch(plt.Rectangle((i-0.5, i-0.5), 1, 1,
                     fill=False, edgecolor='black', linewidth=2))

    plt.colorbar(im, ax=ax, shrink=0.8)

plt.suptitle('Matrix Structure: Tropical Spectral Gap Visualization\n'
             '(Black boxes = diagonal entries; gap = diagonal excess over off-diagonal sum)',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")


"""
Visualization: Tropical Spectral Gap vs. Certified Radius

Shows how the certified robustness radius grows with the tropical spectral
gap, comparing tropical certificates with classical eigenvalue certificates
across multiple matrix dimensions.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def tropical_spectral_gap(Q):
    """Compute Gershgorin diagonal dominance margin."""
    n = Q.shape[0]
    return min(Q[i, i] - sum(abs(Q[i, j]) for j in range(n) if j != i) for i in range(n))


def generate_diag_dominant_matrix(n, gap, seed=42):
    """Generate symmetric diag-dominant matrix with given gap."""
    rng = np.random.RandomState(seed)
    Q = 0.5 * rng.randn(n, n)
    Q = (Q + Q.T) / 2
    for i in range(n):
        off_sum = sum(abs(Q[i, j]) for j in range(n) if j != i)
        Q[i, i] = off_sum + gap
    return Q


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Certified radius vs tropical gap
R = 0.5
gaps = np.linspace(0.1, 10, 200)
r_tropical = np.sqrt(gaps / (2 * R))

axes[0].plot(gaps, r_tropical, 'b-', linewidth=2.5, label='Tropical certificate')
axes[0].fill_between(gaps, 0, r_tropical, alpha=0.15, color='blue')
axes[0].set_xlabel('Tropical Spectral Gap γ', fontsize=12)
axes[0].set_ylabel('Certified Radius r', fontsize=12)
axes[0].set_title('Certified Radius vs. Tropical Gap', fontsize=13)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3)
axes[0].set_xlim(0, 10)

# Plot 2: Tropical gap vs minimum eigenvalue (scatter)
dims = [5, 10, 20]
colors = ['#2196F3', '#4CAF50', '#FF9800']
for dim, color in zip(dims, colors):
    g_vals, e_vals = [], []
    for seed in range(100):
        gap = np.random.RandomState(seed + 1000).uniform(0.5, 5.0)
        Q = generate_diag_dominant_matrix(dim, gap, seed=seed)
        g_vals.append(tropical_spectral_gap(Q))
        e_vals.append(float(np.linalg.eigvalsh(Q).min()))
    axes[1].scatter(g_vals, e_vals, s=20, alpha=0.6, color=color, label=f'n={dim}')

max_val = 8
axes[1].plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='y=x')
axes[1].set_xlabel('Tropical Gap γ', fontsize=12)
axes[1].set_ylabel('Min Eigenvalue λ_min', fontsize=12)
axes[1].set_title('Tropical Gap ≤ Min Eigenvalue', fontsize=13)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

# Plot 3: Energy barrier
r_range = np.linspace(0, 3.5, 200)
alpha = 4.0
R_val = 0.3
actual = np.maximum(0, (alpha/2)*r_range**2 - R_val*r_range**4)
guaranteed = (alpha/4)*r_range**2
valid_mask = R_val * r_range**2 <= alpha/4

axes[2].plot(r_range, actual, 'b-', linewidth=2.5, label='Actual barrier')
axes[2].plot(r_range[valid_mask], guaranteed[valid_mask], 'r--', linewidth=2,
             label='Guaranteed (α/4)r²')
r_crit = np.sqrt(alpha / (2*R_val))
axes[2].axvline(x=r_crit, color='gray', linestyle=':', alpha=0.5, label=f'r_crit={r_crit:.2f}')
axes[2].set_xlabel('Radius r', fontsize=12)
axes[2].set_ylabel('Energy Barrier Height', fontsize=12)
axes[2].set_title('Energy Barrier Theorem', fontsize=13)
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_tropical_gap.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_gap.png")


"""
Visualization: Trust-Region Margin from Tropical Spectral Gap

Shows how the tropical spectral gap controls trust-region model improvement
bounds, connecting adversarial robustness to optimization convergence.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Plot 1: Trust-region model curves for different gaps
s_range = np.linspace(0, 4, 300)
G = 2.0
alphas = [0.5, 1.0, 2.0, 5.0, 10.0]
cmap = plt.cm.viridis(np.linspace(0.2, 0.9, len(alphas)))

for alpha, color in zip(alphas, cmap):
    model = -G * s_range + 0.5 * alpha * s_range**2
    margin = -G**2 / (2 * alpha)
    s_star = G / alpha
    axes[0].plot(s_range, model, linewidth=2, color=color, label=f'γ={alpha}')
    axes[0].plot(s_star, margin, 'o', color=color, markersize=6)

axes[0].axhline(y=0, color='k', linewidth=0.5)
axes[0].set_xlabel('Step size s', fontsize=12)
axes[0].set_ylabel('Model improvement', fontsize=12)
axes[0].set_title(f'Trust-Region Model (G={G})', fontsize=13)
axes[0].legend(fontsize=10, title='Tropical gap γ')
axes[0].grid(True, alpha=0.3)
axes[0].set_ylim(-5, 15)

# Plot 2: Worst-case margin vs tropical gap
gaps = np.linspace(0.1, 10, 200)
G_values = [0.5, 1.0, 2.0, 5.0]
colors2 = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']

for G_val, color in zip(G_values, colors2):
    margins = -G_val**2 / (2 * gaps)
    axes[1].plot(gaps, margins, linewidth=2, color=color, label=f'G={G_val}')

axes[1].axhline(y=0, color='k', linewidth=0.5)
axes[1].set_xlabel('Tropical Spectral Gap γ', fontsize=12)
axes[1].set_ylabel('Worst-case margin -G²/(2γ)', fontsize=12)
axes[1].set_title('Trust-Region Margin Bound', fontsize=13)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)
axes[1].set_ylim(-15, 1)

plt.tight_layout()
plt.savefig('viz_trust_region.png', dpi=150, bbox_inches='tight')
print("Saved viz_trust_region.png")
