#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Polyhedral Robustness

Demonstrates how the formalized theorems apply to practical ML scenarios:
1. MNIST-style digit classification robustness
2. Adversarial attack detection
3. Robustness map visualization
4. Comparison of polyhedral vs. Lipschitz certificates
"""

import numpy as np
from algorithms import PolyhedralCertifier, RobustnessCertificate
from typing import List, Tuple


def simulate_relu_network(n_features: int, n_hidden: int, n_classes: int,
                           seed: int = 42) -> Tuple[np.ndarray, np.ndarray]:
    """
    Simulate the output layer of a trained ReLU network.
    
    After all hidden layers, a ReLU network produces piecewise-affine
    output. Within each linearity region, the network acts as an
    affine map x ↦ Wx + b. This function generates realistic
    weight/bias pairs for the final affine piece.
    """
    np.random.seed(seed)
    # Simulate weight matrix (like a trained network's final linear layer)
    W = np.random.randn(n_classes, n_features) * 0.3
    # Add class-specific structure (each class has preferred directions)
    for i in range(n_classes):
        direction = np.zeros(n_features)
        direction[i % n_features] = 1.0
        if (i + 1) % n_features < n_features:
            direction[(i + 1) % n_features] = 0.5
        W[i] += direction * 0.5
    
    b = np.random.randn(n_classes) * 0.1
    return W, b


def adversarial_attack_detection(certifier: PolyhedralCertifier,
                                  x_clean: np.ndarray,
                                  perturbation_budget: float) -> dict:
    """
    Analyze vulnerability to adversarial attacks using polyhedral certificates.
    
    For a clean input x, determines:
    - Whether the point is certifiably robust at the given budget
    - The maximum safe perturbation
    - Which competitor class is the closest threat
    """
    cert = certifier.certify(x_clean)
    
    is_certifiably_robust = cert.certified_radius > perturbation_budget
    
    # Find the ranking of threats
    threat_ranking = sorted(cert.normalized_margins.items(), 
                           key=lambda x: x[1])
    
    return {
        'is_robust': is_certifiably_robust,
        'certified_radius': cert.certified_radius,
        'perturbation_budget': perturbation_budget,
        'safety_margin': cert.certified_radius - perturbation_budget,
        'predicted_class': cert.predicted_class,
        'top_threat': threat_ranking[0] if threat_ranking else None,
        'threat_ranking': threat_ranking,
        'lipschitz_says_robust': cert.lipschitz_radius > perturbation_budget,
    }


def robustness_landscape(certifier: PolyhedralCertifier,
                          center: np.ndarray,
                          direction1: np.ndarray,
                          direction2: np.ndarray,
                          grid_size: int = 50,
                          extent: float = 3.0) -> dict:
    """
    Compute robustness certificate values over a 2D grid.
    
    Projects the high-dimensional space onto a 2D plane defined
    by two directions, computing certificates at each grid point.
    """
    t1 = np.linspace(-extent, extent, grid_size)
    t2 = np.linspace(-extent, extent, grid_size)
    
    radii = np.zeros((grid_size, grid_size))
    classes = np.zeros((grid_size, grid_size), dtype=int)
    
    for i, s1 in enumerate(t1):
        for j, s2 in enumerate(t2):
            x = center + s1 * direction1 + s2 * direction2
            cert = certifier.certify(x)
            radii[i, j] = cert.certified_radius
            classes[i, j] = cert.predicted_class
    
    return {
        't1': t1, 't2': t2,
        'radii': radii,
        'classes': classes,
    }


if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Simulated Neural Network Robustness Analysis")
    print("=" * 70)
    
    # Simulate a 5-class classifier in ℝ¹⁰
    W, b = simulate_relu_network(n_features=10, n_hidden=32, n_classes=5)
    certifier = PolyhedralCertifier(W, b)
    
    # Generate test points
    np.random.seed(99)
    n_test = 200
    X_test = np.random.randn(n_test, 10) * 0.3
    
    certs = certifier.batch_certify(X_test)
    
    radii = [c.certified_radius for c in certs]
    lip_radii = [c.lipschitz_radius for c in certs]
    improvements = [c.certified_radius / c.lipschitz_radius 
                   for c in certs if c.lipschitz_radius > 1e-12]
    
    print(f"\n  Classifier: 5 classes, 10 features")
    print(f"  Test points: {n_test}")
    print(f"\n  Polyhedral certificates:")
    print(f"    Mean radius:   {np.mean(radii):.4f}")
    print(f"    Median radius: {np.median(radii):.4f}")
    print(f"    Min radius:    {np.min(radii):.4f}")
    print(f"    Max radius:    {np.max(radii):.4f}")
    print(f"\n  Lipschitz certificates:")
    print(f"    Mean radius:   {np.mean(lip_radii):.4f}")
    print(f"    Median radius: {np.median(lip_radii):.4f}")
    print(f"\n  Improvement (polyhedral / Lipschitz):")
    print(f"    Mean:   {np.mean(improvements):.2f}x")
    print(f"    Median: {np.median(improvements):.2f}x")
    print(f"    Max:    {np.max(improvements):.2f}x")
    
    # Application 2: Adversarial attack detection
    print("\n" + "=" * 70)
    print("APPLICATION 2: Adversarial Attack Detection")
    print("=" * 70)
    
    budgets = [0.05, 0.1, 0.2, 0.5, 1.0]
    
    for budget in budgets:
        robust_poly = sum(1 for c in certs if c.certified_radius > budget)
        robust_lip = sum(1 for c in certs if c.lipschitz_radius > budget)
        print(f"\n  ε = {budget}:")
        print(f"    Certified robust (polyhedral): {robust_poly}/{n_test} "
              f"({100*robust_poly/n_test:.1f}%)")
        print(f"    Certified robust (Lipschitz):  {robust_lip}/{n_test} "
              f"({100*robust_lip/n_test:.1f}%)")
        print(f"    Additional points certified:   {robust_poly - robust_lip}")
    
    # Application 3: Threat analysis
    print("\n" + "=" * 70)
    print("APPLICATION 3: Detailed Threat Analysis")
    print("=" * 70)
    
    x_sample = X_test[0]
    analysis = adversarial_attack_detection(certifier, x_sample, 0.15)
    
    print(f"\n  Input point: {x_sample[:3]}... (10-dim)")
    print(f"  Predicted class: {analysis['predicted_class']}")
    print(f"  Certified radius: {analysis['certified_radius']:.4f}")
    print(f"  Budget: {analysis['perturbation_budget']}")
    print(f"  Certifiably robust? {analysis['is_robust']}")
    print(f"  Safety margin: {analysis['safety_margin']:.4f}")
    
    if analysis['top_threat']:
        j, margin = analysis['top_threat']
        print(f"  Closest threat: class {j} (normalized margin = {margin:.4f})")
    
    print(f"\n  Threat ranking:")
    for j, margin in analysis['threat_ranking'][:5]:
        print(f"    Class {j}: normalized margin = {margin:.4f}")
    
    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Tropical Polyhedral Robustness: Concrete Numerical Examples

Demonstrates the core theorems with explicit numerical computations:
1. Distance from a point to an affine hyperplane
2. Tropical cells as intersections of halfspaces
3. Certified robustness radii from normalized margins
4. Comparison with global Lipschitz certificates
"""

import numpy as np
from typing import List, Tuple

def inner(u: np.ndarray, x: np.ndarray) -> float:
    """Inner product ⟪u, x⟫."""
    return float(np.dot(u, x))

def affine_form(a: np.ndarray, b: float, x: np.ndarray) -> float:
    """Evaluate affine form ℓ(x) = ⟪a, x⟫ + b."""
    return inner(a, x) + b

def dist_to_hyperplane(u: np.ndarray, c: float, x: np.ndarray) -> float:
    """
    Distance from point x to hyperplane {y | ⟪u, y⟫ = c}.
    
    Formula: |⟪u, x⟫ - c| / ‖u‖
    
    This is the atomic geometric lemma (Theorem: dist_to_hyperplane_eq).
    """
    return abs(inner(u, x) - c) / np.linalg.norm(u)

def dist_to_tie_hyperplane(a1: np.ndarray, b1: float,
                            a2: np.ndarray, b2: float,
                            x: np.ndarray) -> float:
    """
    Distance from x to the tie hyperplane {y | ⟪a₁, y⟫ + b₁ = ⟪a₂, y⟫ + b₂}.
    
    Formula: |ℓ₁(x) - ℓ₂(x)| / ‖a₁ - a₂‖
    
    This is Theorem: dist_to_tie_hyperplane_eq.
    """
    gap = affine_form(a1, b1, x) - affine_form(a2, b2, x)
    return abs(gap) / np.linalg.norm(a1 - a2)

def tropical_cell_membership(a_list: List[np.ndarray], b_list: List[float],
                              k: int, x: np.ndarray) -> bool:
    """Check if x belongs to tropical cell C_k."""
    score_k = affine_form(a_list[k], b_list[k], x)
    return all(affine_form(a_list[j], b_list[j], x) <= score_k + 1e-12
               for j in range(len(a_list)))

def certified_radius(a_list: List[np.ndarray], b_list: List[float],
                      k: int, x: np.ndarray) -> float:
    """
    Compute the polyhedral certified robustness radius at point x for class k.
    
    This is the minimum over all competitors j ≠ k of:
        (ℓ_k(x) - ℓ_j(x)) / ‖a_k - a_j‖
    
    By Theorem ball_subset_tropicalCell, any perturbation within this
    radius preserves the classification.
    """
    score_k = affine_form(a_list[k], b_list[k], x)
    radius = float('inf')
    for j in range(len(a_list)):
        if j == k:
            continue
        gap = score_k - affine_form(a_list[j], b_list[j], x)
        norm_diff = np.linalg.norm(a_list[k] - a_list[j])
        if norm_diff < 1e-15:
            if gap < -1e-12:
                return 0.0
            continue
        radius = min(radius, gap / norm_diff)
    return radius

def lipschitz_certified_radius(a_list: List[np.ndarray], b_list: List[float],
                                k: int, x: np.ndarray) -> float:
    """
    Global Lipschitz certificate: margin / (2 * max_norm).
    
    This is the baseline from tropical_affine_lipschitz_certified_robustness.
    The polyhedral certificate is always at least as sharp.
    """
    score_k = affine_form(a_list[k], b_list[k], x)
    margin = min(score_k - affine_form(a_list[j], b_list[j], x)
                 for j in range(len(a_list)) if j != k)
    K = max(np.linalg.norm(a_list[j]) for j in range(len(a_list)))
    return margin / (2 * K) if K > 0 else float('inf')


# ═══════════════════════════════════════════════════════════════
# Example 1: Distance to hyperplane in ℝ²
# ═══════════════════════════════════════════════════════════════
print("=" * 70)
print("EXAMPLE 1: Distance to Affine Hyperplane in ℝ²")
print("=" * 70)

u = np.array([3.0, 4.0])
c = 10.0
x = np.array([1.0, 1.0])

d = dist_to_hyperplane(u, c, x)
print(f"  Hyperplane: {{y | ⟪[3, 4], y⟫ = 10}}")
print(f"  Point:      x = [1, 1]")
print(f"  ⟪u, x⟫ = {inner(u, x)}")
print(f"  |⟪u, x⟫ - c| = {abs(inner(u, x) - c)}")
print(f"  ‖u‖ = {np.linalg.norm(u)}")
print(f"  Distance = |⟪u, x⟫ - c| / ‖u‖ = {d}")
print(f"  Expected: |7 - 10| / 5 = 3/5 = {3/5}")
print()

# ═══════════════════════════════════════════════════════════════
# Example 2: Tropical cell in ℝ² with 3 classes
# ═══════════════════════════════════════════════════════════════
print("=" * 70)
print("EXAMPLE 2: Tropical Cell (3-class classifier in ℝ²)")
print("=" * 70)

# Three affine forms: ℓ_i(x) = ⟪a_i, x⟫ + b_i
a = [np.array([2.0, 1.0]),   # class 0
     np.array([-1.0, 3.0]),  # class 1
     np.array([0.0, -2.0])]  # class 2
b = [0.0, 1.0, 5.0]

x = np.array([1.0, 2.0])
print(f"  Affine forms:")
for i in range(3):
    score = affine_form(a[i], b[i], x)
    print(f"    ℓ_{i}(x) = ⟪{a[i]}, x⟫ + {b[i]} = {score}")

winner = max(range(3), key=lambda i: affine_form(a[i], b[i], x))
print(f"\n  Winner at x = [{x[0]}, {x[1]}]: class {winner}")
print(f"  In tropical cell C_{winner}? {tropical_cell_membership(a, b, winner, x)}")

# Certified radius
r_poly = certified_radius(a, b, winner, x)
r_lip = lipschitz_certified_radius(a, b, winner, x)
print(f"\n  Polyhedral certified radius:  {r_poly:.6f}")
print(f"  Lipschitz certified radius:   {r_lip:.6f}")
print(f"  Improvement factor:           {r_poly / r_lip:.2f}x")

# Verify robustness by sampling
print(f"\n  Verification: sampling 1000 points in ball of radius {r_poly * 0.99:.4f}...")
np.random.seed(42)
violations = 0
for _ in range(1000):
    delta = np.random.randn(2)
    delta = delta / np.linalg.norm(delta) * r_poly * 0.99 * np.random.random()
    y = x + delta
    if not tropical_cell_membership(a, b, winner, y):
        violations += 1
print(f"  Classification changes: {violations} (should be 0)")
print()

# ═══════════════════════════════════════════════════════════════
# Example 3: Distance to each tie hyperplane
# ═══════════════════════════════════════════════════════════════
print("=" * 70)
print("EXAMPLE 3: Distance to Tie Hyperplanes")
print("=" * 70)

for j in range(3):
    if j == winner:
        continue
    d_tie = dist_to_tie_hyperplane(a[winner], b[winner], a[j], b[j], x)
    gap = affine_form(a[winner], b[winner], x) - affine_form(a[j], b[j], x)
    norm_diff = np.linalg.norm(a[winner] - a[j])
    print(f"  Tie hyperplane ℓ_{winner} = ℓ_{j}:")
    print(f"    Score gap: ℓ_{winner}(x) - ℓ_{j}(x) = {gap:.4f}")
    print(f"    Normal ‖a_{winner} - a_{j}‖ = {norm_diff:.4f}")
    print(f"    Distance = {d_tie:.6f}")
    print(f"    Normalized margin = gap / ‖normal‖ = {gap / norm_diff:.6f}")
    print()

# ═══════════════════════════════════════════════════════════════
# Example 4: High-dimensional ReLU network
# ═══════════════════════════════════════════════════════════════
print("=" * 70)
print("EXAMPLE 4: 10-class Classifier in ℝ²⁰ (simulated ReLU output)")
print("=" * 70)

np.random.seed(123)
n_dim = 20
n_classes = 10
a_high = [np.random.randn(n_dim) for _ in range(n_classes)]
b_high = [np.random.randn() for _ in range(n_classes)]

x_high = np.random.randn(n_dim) * 0.5
scores = [affine_form(a_high[i], b_high[i], x_high) for i in range(n_classes)]
winner_high = int(np.argmax(scores))

r_poly_high = certified_radius(a_high, b_high, winner_high, x_high)
r_lip_high = lipschitz_certified_radius(a_high, b_high, winner_high, x_high)

print(f"  Dimension: {n_dim}, Classes: {n_classes}")
print(f"  Winner: class {winner_high} (score = {scores[winner_high]:.4f})")
print(f"  Margin (min gap): {min(scores[winner_high] - scores[j] for j in range(n_classes) if j != winner_high):.4f}")
print(f"\n  Polyhedral certified radius: {r_poly_high:.6f}")
print(f"  Lipschitz certified radius:  {r_lip_high:.6f}")
if r_lip_high > 0:
    print(f"  Improvement factor:          {r_poly_high / r_lip_high:.2f}x")

print("\n" + "=" * 70)
print("All examples completed successfully.")
print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables."""

import json
import base64
import os

# Read markdown files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read and encode images
def encode_image(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

# Read lean files
lean_files = [
    'Tropical/PolyhedralRobustness/HyperplaneDistance.lean',
    'Tropical/PolyhedralRobustness/TropicalCells.lean',
    'Tropical/PolyhedralRobustness/Robustness.lean',
]

lean_code = ""
for f in lean_files:
    path = os.path.join(os.path.dirname(__file__), f)
    if os.path.exists(path):
        lean_code += f"-- ═══════════════════════════════════════\n-- File: {f}\n-- ═══════════════════════════════════════\n\n"
        lean_code += read_file(path) + "\n\n"

# Read Python files
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
visualizations_code = read_file('visualizations.py')

# Read markdown
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')

# Encode visualizations
viz_data = []
for img_name in ['tropical_cells.png', 'certificate_comparison.png', 'boundary_profile.png']:
    if os.path.exists(img_name):
        viz_data.append({
            "name": img_name.replace('.png', '').replace('_', ' ').title(),
            "data": encode_image(img_name)
        })

# Build package
package = {
    "title": "Polyhedral Geometry Route to Tropical Robustness and Information Contraction",
    "domain": "Tropical Geometry / Certified Robustness / Polyhedral Analysis",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Polyhedral Robustness Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Polyhedral Certifier",
            "pseudocode": """Algorithm: PolyhedralCertifier.certify(x)
Input: Point x, weight matrix W, bias vector b
Output: RobustnessCertificate

1. Compute scores s_i = W_i · x + b_i for all classes i
2. Set k = argmax_i s_i (predicted class)
3. For each competitor j ≠ k:
   a. Compute gap = s_k - s_j
   b. Compute normal_norm = ||W_k - W_j||
   c. If normal_norm > 0:
      normalized_margin_j = gap / normal_norm
4. Return min_j normalized_margin_j as certified radius

Complexity: O(C × d) per point, where C = classes, d = features
Precomputation: O(C² × d) for pairwise normal norms""",
            "code": algorithms_code
        }
    ],
    "visualizations": viz_data,
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")
print(f"  Article: {len(article)} chars")
print(f"  Research paper: {len(research_paper)} chars")
print(f"  Future directions: {len(future_directions)} chars")
print(f"  Lean proofs: {len(lean_code)} chars")
print(f"  Visualizations: {len(viz_data)}")


#!/usr/bin/env python3
"""
visualizations.py — Visualization of Tropical Polyhedral Robustness

Generates publication-quality figures showing:
1. Tropical cells and decision boundaries in ℝ²
2. Robustness certificate heatmaps
3. Comparison of polyhedral vs Lipschitz certificates
4. Boundary distance profiles
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import matplotlib.patches as mpatches
import base64
import io
from algorithms import PolyhedralCertifier, BoundaryDistanceComputer


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_tropical_cells_and_robustness():
    """
    Figure 1: Tropical cells, decision boundaries, and certified radii in ℝ².
    """
    W = np.array([[2.0, 1.0], [-1.0, 3.0], [0.0, -2.0]])
    b = np.array([0.0, 1.0, 5.0])
    certifier = PolyhedralCertifier(W, b)
    
    # Grid
    x_range = np.linspace(-3, 5, 400)
    y_range = np.linspace(-3, 5, 400)
    XX, YY = np.meshgrid(x_range, y_range)
    
    classes = np.zeros_like(XX, dtype=int)
    radii = np.zeros_like(XX)
    
    for i in range(XX.shape[0]):
        for j in range(XX.shape[1]):
            pt = np.array([XX[i, j], YY[i, j]])
            cert = certifier.certify(pt)
            classes[i, j] = cert.predicted_class
            radii[i, j] = cert.certified_radius
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Decision regions
    ax = axes[0]
    colors = ['#2196F3', '#FF5722', '#4CAF50']
    cmap = ListedColormap(colors)
    ax.contourf(XX, YY, classes, levels=[-0.5, 0.5, 1.5, 2.5], 
                colors=colors, alpha=0.3)
    ax.contour(XX, YY, classes, levels=[0.5, 1.5], colors='black', 
               linewidths=2, linestyles='-')
    
    # Mark a point with its certificate
    x_demo = np.array([1.0, 2.0])
    cert_demo = certifier.certify(x_demo)
    circle = plt.Circle(x_demo, cert_demo.certified_radius, 
                        fill=False, color='red', linewidth=2, linestyle='--')
    ax.add_patch(circle)
    ax.plot(*x_demo, 'ro', markersize=8, zorder=5)
    ax.annotate(f'r = {cert_demo.certified_radius:.3f}', 
                xy=x_demo, xytext=(x_demo[0]+0.3, x_demo[1]+0.5),
                fontsize=10, color='red',
                arrowprops=dict(arrowstyle='->', color='red'))
    
    patches = [mpatches.Patch(color=c, alpha=0.3, label=f'Class {i}') 
               for i, c in enumerate(colors)]
    ax.legend(handles=patches, loc='upper left', fontsize=10)
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Tropical Cells & Decision Boundaries', fontsize=14)
    ax.set_xlim(-3, 5)
    ax.set_ylim(-3, 5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    
    # Right: Robustness heatmap
    ax = axes[1]
    im = ax.contourf(XX, YY, radii, levels=20, cmap='viridis')
    ax.contour(XX, YY, classes, levels=[0.5, 1.5], colors='white', 
               linewidths=1.5, linestyles='-')
    plt.colorbar(im, ax=ax, label='Certified Radius')
    ax.plot(*x_demo, 'r*', markersize=15, zorder=5)
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Polyhedral Robustness Certificate', fontsize=14)
    ax.set_xlim(-3, 5)
    ax.set_ylim(-3, 5)
    ax.set_aspect('equal')
    
    fig.suptitle('Tropical Polyhedral Geometry of Decision Boundaries', 
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    return fig


def plot_certificate_comparison():
    """
    Figure 2: Polyhedral vs Lipschitz certificate comparison.
    """
    np.random.seed(42)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Scatter plot of certificates
    ax = axes[0]
    n_classes_list = [3, 5, 10]
    markers = ['o', 's', '^']
    colors = ['#2196F3', '#FF5722', '#4CAF50']
    
    for idx, nc in enumerate(n_classes_list):
        W = np.random.randn(nc, 10) * 0.5
        b = np.random.randn(nc) * 0.1
        certifier = PolyhedralCertifier(W, b)
        
        X = np.random.randn(100, 10) * 0.3
        certs = certifier.batch_certify(X)
        
        poly_r = [c.certified_radius for c in certs]
        lip_r = [c.lipschitz_radius for c in certs]
        
        ax.scatter(lip_r, poly_r, alpha=0.5, marker=markers[idx],
                  color=colors[idx], label=f'{nc} classes', s=30)
    
    max_val = ax.get_xlim()[1]
    ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='y = x')
    ax.set_xlabel('Lipschitz Certificate', fontsize=12)
    ax.set_ylabel('Polyhedral Certificate', fontsize=12)
    ax.set_title('Certificate Comparison (always above diagonal)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Right: Improvement factor distribution
    ax = axes[1]
    all_improvements = []
    for nc in [3, 5, 10, 20]:
        W = np.random.randn(nc, 20) * 0.5
        b = np.random.randn(nc) * 0.1
        certifier = PolyhedralCertifier(W, b)
        
        X = np.random.randn(200, 20) * 0.3
        certs = certifier.batch_certify(X)
        
        improvements = [c.certified_radius / c.lipschitz_radius 
                       for c in certs if c.lipschitz_radius > 1e-12]
        all_improvements.append(improvements)
    
    bp = ax.boxplot(all_improvements, labels=['3', '5', '10', '20'],
                    patch_artist=True)
    colors_box = ['#BBDEFB', '#FFCCBC', '#C8E6C9', '#E1BEE7']
    for patch, color in zip(bp['boxes'], colors_box):
        patch.set_facecolor(color)
    
    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='No improvement')
    ax.set_xlabel('Number of Classes', fontsize=12)
    ax.set_ylabel('Improvement Factor (Poly/Lip)', fontsize=12)
    ax.set_title('Polyhedral Certificate Improvement', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')
    
    fig.suptitle('Polyhedral Certificates Dominate Lipschitz Certificates', 
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    return fig


def plot_boundary_distance_profile():
    """
    Figure 3: Distance profile along a path crossing decision boundaries.
    """
    W = np.array([[2.0, 1.0], [-1.0, 3.0], [0.0, -2.0]])
    b = np.array([0.0, 1.0, 5.0])
    certifier = PolyhedralCertifier(W, b)
    bdc = BoundaryDistanceComputer(certifier)
    
    # Path from (-2, -2) to (4, 4)
    t_vals = np.linspace(0, 1, 500)
    start = np.array([-2.0, -2.0])
    end = np.array([4.0, 4.0])
    
    classes = []
    cert_radii = []
    lip_radii = []
    facet_dists = {0: [], 1: [], 2: []}
    
    for t in t_vals:
        pt = start + t * (end - start)
        cert = certifier.certify(pt)
        classes.append(cert.predicted_class)
        cert_radii.append(cert.certified_radius)
        lip_radii.append(cert.lipschitz_radius)
        
        k = cert.predicted_class
        dists = bdc.facet_distances(pt, k)
        for j in range(3):
            if j in dists:
                facet_dists[j].append(dists[j])
            else:
                facet_dists[j].append(np.nan)
    
    fig, axes = plt.subplots(2, 1, figsize=(12, 8), sharex=True)
    
    # Top: Certificate radii
    ax = axes[0]
    ax.plot(t_vals, cert_radii, 'b-', linewidth=2, label='Polyhedral certificate')
    ax.plot(t_vals, lip_radii, 'r--', linewidth=1.5, label='Lipschitz certificate')
    ax.fill_between(t_vals, lip_radii, cert_radii, alpha=0.15, color='green',
                    label='Improvement region')
    
    # Mark boundary crossings
    for i in range(1, len(classes)):
        if classes[i] != classes[i-1]:
            ax.axvline(x=t_vals[i], color='gray', linestyle=':', alpha=0.7)
    
    ax.set_ylabel('Certified Radius', fontsize=12)
    ax.set_title('Robustness Along a Path Through Feature Space', fontsize=14)
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0)
    
    # Bottom: Class labels
    ax = axes[1]
    class_colors = ['#2196F3', '#FF5722', '#4CAF50']
    for i in range(len(t_vals) - 1):
        ax.axvspan(t_vals[i], t_vals[i+1], 
                  color=class_colors[classes[i]], alpha=0.4)
    
    ax.set_xlabel('Path Parameter t', fontsize=12)
    ax.set_ylabel('Predicted Class', fontsize=12)
    ax.set_yticks([0, 1, 2])
    ax.set_title('Classification Along Path', fontsize=14)
    
    fig.suptitle('Tropical Decision Boundary Crossing Profile', 
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")
    
    fig1 = plot_tropical_cells_and_robustness()
    fig1.savefig('tropical_cells.png', dpi=150, bbox_inches='tight')
    print("  Saved tropical_cells.png")
    
    fig2 = plot_certificate_comparison()
    fig2.savefig('certificate_comparison.png', dpi=150, bbox_inches='tight')
    print("  Saved certificate_comparison.png")
    
    fig3 = plot_boundary_distance_profile()
    fig3.savefig('boundary_profile.png', dpi=150, bbox_inches='tight')
    print("  Saved boundary_profile.png")
    
    print("All visualizations generated.")
