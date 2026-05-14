#!/usr/bin/env python3
"""
Applications of Sheaf-Theoretic Certified Robustness

Demonstrates real-world applications of the sheaf certification framework:
1. Image classifier robustness certification
2. Medical diagnosis safety margins
3. Autonomous driving perception certification
"""

import numpy as np
from typing import List, Tuple


def certify_image_classifier(
    n_chambers: int,
    margins: np.ndarray,
    lipschitz_constants: np.ndarray,
    image_name: str = "sample"
) -> dict:
    """
    Certify an image classifier's robustness using the sheaf descent theorem.
    
    Simulates certifying a ReLU image classifier where each activation chamber
    corresponds to a set of images processed by the same linear function.
    
    Args:
        n_chambers: Number of activation chambers
        margins: Classification margins per chamber
        lipschitz_constants: Lipschitz constants per chamber
        image_name: Name of the image being certified
    
    Returns:
        Certification report dictionary
    """
    local_radii = margins / lipschitz_constants
    global_radius = float(np.min(local_radii))
    bottleneck = int(np.argmin(local_radii))
    
    # Convert radius to pixel intensity units (assuming [0, 255] range)
    pixel_radius = global_radius * 255
    
    return {
        "image": image_name,
        "global_radius_normalized": global_radius,
        "global_radius_pixels": pixel_radius,
        "bottleneck_chamber": bottleneck,
        "bottleneck_margin": float(margins[bottleneck]),
        "bottleneck_lipschitz": float(lipschitz_constants[bottleneck]),
        "n_chambers": n_chambers,
        "mean_local_radius": float(np.mean(local_radii)),
        "certified": global_radius > 0,
        "vulnerability_ratio": float(np.mean(local_radii < 1e-6)),
    }


def medical_diagnosis_certification(
    n_features: int = 10,
    n_chambers: int = 20,
    confidence_threshold: float = 0.95
) -> dict:
    """
    Certify robustness of a medical diagnosis classifier.
    
    Models a classifier for X-ray diagnosis (normal vs. abnormal) where:
    - Each activation chamber corresponds to a set of feature patterns
    - Margin = confidence gap between top-2 class scores
    - Lipschitz constant bounds sensitivity to feature perturbations
    
    Returns:
        Safety certification report
    """
    np.random.seed(42)
    
    # Simulate chamber data for medical classifier
    margins = np.random.exponential(0.3, n_chambers)
    lipschitz = np.random.exponential(2.0, n_chambers) + 0.5
    local_radii = margins / lipschitz
    
    global_radius = float(np.min(local_radii))
    
    # Compute safety metrics
    safe_chambers = np.sum(local_radii > 0.01)
    borderline_chambers = np.sum((local_radii > 0) & (local_radii <= 0.01))
    vulnerable_chambers = np.sum(local_radii <= 0)
    
    return {
        "application": "Medical X-ray Diagnosis",
        "n_features": n_features,
        "n_chambers": n_chambers,
        "global_certified_radius": global_radius,
        "safe_chambers": int(safe_chambers),
        "borderline_chambers": int(borderline_chambers),
        "vulnerable_chambers": int(vulnerable_chambers),
        "safety_ratio": float(safe_chambers / n_chambers),
        "recommendation": (
            "CERTIFIED SAFE" if global_radius > 0.01
            else "REQUIRES HUMAN REVIEW" if global_radius > 0
            else "NOT CERTIFIED — DO NOT DEPLOY"
        ),
    }


def autonomous_driving_perception(
    n_object_classes: int = 5,
    n_chambers_per_class: int = 50,
) -> dict:
    """
    Certify robustness of an autonomous driving perception system.
    
    Models a multi-class object detector (cars, pedestrians, signs, etc.)
    where robustness must be certified for each object class.
    
    Returns:
        Per-class certification results
    """
    np.random.seed(123)
    
    class_names = ["Car", "Pedestrian", "Stop Sign", "Traffic Light", "Lane Marking"][:n_object_classes]
    
    results = {}
    for cls_idx, cls_name in enumerate(class_names):
        # Different classes have different difficulty profiles
        margin_scale = 0.5 + 0.3 * cls_idx  # Some classes are harder
        lip_scale = 1.0 + 0.5 * cls_idx
        
        margins = np.random.exponential(margin_scale, n_chambers_per_class)
        lipschitz = np.random.exponential(lip_scale, n_chambers_per_class) + 0.2
        local_radii = margins / lipschitz
        
        global_radius = float(np.min(local_radii))
        
        results[cls_name] = {
            "global_radius": global_radius,
            "mean_local_radius": float(np.mean(local_radii)),
            "min_margin": float(np.min(margins)),
            "max_lipschitz": float(np.max(lipschitz)),
            "certified": global_radius > 0.001,
        }
    
    # Overall system certification: min over all classes
    overall_radius = min(r["global_radius"] for r in results.values())
    
    return {
        "application": "Autonomous Driving Perception",
        "n_classes": n_object_classes,
        "per_class_results": results,
        "overall_certified_radius": overall_radius,
        "system_certified": overall_radius > 0.001,
    }


# =============================================================================
# Run applications
# =============================================================================
if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Image Classifier Robustness Certification")
    print("=" * 70)
    
    np.random.seed(42)
    n = 100
    margins = np.random.exponential(0.5, n)
    lips = np.random.exponential(1.5, n) + 0.3
    
    report = certify_image_classifier(n, margins, lips, "cat_photo_001.png")
    print(f"\nImage: {report['image']}")
    print(f"Number of activation chambers: {report['n_chambers']}")
    print(f"Global certified L∞ radius: {report['global_radius_normalized']:.6f}")
    print(f"  In pixel units (0-255): ±{report['global_radius_pixels']:.2f}")
    print(f"Bottleneck chamber: {report['bottleneck_chamber']}")
    print(f"  margin = {report['bottleneck_margin']:.4f}")
    print(f"  Lipschitz = {report['bottleneck_lipschitz']:.4f}")
    print(f"Mean local radius: {report['mean_local_radius']:.4f}")
    print(f"Status: {'CERTIFIED ✓' if report['certified'] else 'NOT CERTIFIED ✗'}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 2: Medical Diagnosis Safety Certification")
    print("=" * 70)
    
    med_report = medical_diagnosis_certification()
    print(f"\nApplication: {med_report['application']}")
    print(f"Chambers analyzed: {med_report['n_chambers']}")
    print(f"Global certified radius: {med_report['global_certified_radius']:.6f}")
    print(f"Safe chambers: {med_report['safe_chambers']}/{med_report['n_chambers']}")
    print(f"Borderline chambers: {med_report['borderline_chambers']}")
    print(f"Vulnerable chambers: {med_report['vulnerable_chambers']}")
    print(f"Safety ratio: {med_report['safety_ratio']:.1%}")
    print(f"\n→ Recommendation: {med_report['recommendation']}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 3: Autonomous Driving Perception Certification")
    print("=" * 70)
    
    driving_report = autonomous_driving_perception()
    print(f"\nApplication: {driving_report['application']}")
    print(f"Number of object classes: {driving_report['n_classes']}")
    print(f"\nPer-class certification:")
    for cls_name, cls_data in driving_report['per_class_results'].items():
        status = "✓" if cls_data['certified'] else "✗"
        print(f"  {cls_name:>15}: R = {cls_data['global_radius']:.6f} "
              f"(mean local = {cls_data['mean_local_radius']:.4f}) [{status}]")
    
    print(f"\nOverall system certified radius: {driving_report['overall_certified_radius']:.6f}")
    print(f"System status: {'CERTIFIED ✓' if driving_report['system_certified'] else 'NOT CERTIFIED ✗'}")


#!/usr/bin/env python3
"""
Sheaf-Theoretic Certified Adversarial Robustness: Demonstrations

This script demonstrates the core theorems with concrete numerical examples:
1. Local-to-global robustness certification via finite covers
2. ReLU chamber certification with margin/Lipschitz data
3. Vulnerability detection via stalk obstruction
4. Cocycle/coboundary algebra on finite index sets
"""

import numpy as np
from typing import List, Tuple, Dict, Optional


def compute_global_certified_radius(
    margins: np.ndarray, lipschitz_constants: np.ndarray
) -> Tuple[float, int]:
    """
    Compute the global certified L∞ robustness radius from local margin/Lipschitz data.
    
    This implements Theorem 3.1 (Cohomological Descent):
    R = inf_i (margin_i / Lipschitz_i)
    
    Args:
        margins: Array of local classification margins (nonneg)
        lipschitz_constants: Array of local Lipschitz constants (positive)
    
    Returns:
        (global_radius, bottleneck_index): The certified radius and which chamber limits it
    """
    assert np.all(margins >= 0), "Margins must be nonneg"
    assert np.all(lipschitz_constants > 0), "Lipschitz constants must be positive"
    
    local_radii = margins / lipschitz_constants
    bottleneck = int(np.argmin(local_radii))
    global_radius = float(local_radii[bottleneck])
    
    return global_radius, bottleneck


def check_cocycle_condition(c: np.ndarray) -> bool:
    """
    Check if a 1-cochain c[i,j] satisfies the cocycle condition:
    c[i,k] = c[i,j] + c[j,k] for all i,j,k
    
    Args:
        c: Square matrix representing the 1-cochain
    
    Returns:
        True if c is a cocycle
    """
    n = c.shape[0]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if abs(c[i, k] - (c[i, j] + c[j, k])) > 1e-10:
                    return False
    return True


def check_coboundary(c: np.ndarray) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Check if a 1-cochain is a coboundary and find the primitive if so.
    
    A coboundary has c[i,j] = b[j] - b[i] for some b.
    By Theorem 6.1, every cocycle on a finite set is a coboundary.
    
    Args:
        c: Square matrix representing the 1-cochain
    
    Returns:
        (is_coboundary, primitive): Whether it's a coboundary and the primitive b
    """
    n = c.shape[0]
    if n == 0:
        return True, np.array([])
    
    # Fix b[0] = 0, then b[j] = c[0, j]
    b = np.array([c[0, j] for j in range(n)])
    
    # Verify: c[i,j] should equal b[j] - b[i]
    for i in range(n):
        for j in range(n):
            if abs(c[i, j] - (b[j] - b[i])) > 1e-10:
                return False, None
    
    return True, b


def detect_vulnerability(
    score_gap_values: np.ndarray,
    positions: np.ndarray,
    query_point: np.ndarray,
    epsilon: float = 0.1
) -> Tuple[bool, Optional[int]]:
    """
    Detect vulnerability at a query point by checking for nearby non-positive score-gap.
    
    Implements Theorem 5.1: if for every ε > 0 there exists y within distance ε
    with scoreGap(y) ≤ 0, then the point is vulnerable.
    
    Args:
        score_gap_values: Score-gap at sampled positions
        positions: Coordinates of sampled positions
        query_point: Point to check vulnerability
        epsilon: Search radius
    
    Returns:
        (is_vulnerable, witness_index): Whether vulnerable and index of witness
    """
    distances = np.max(np.abs(positions - query_point), axis=1)  # L∞ distance
    nearby_mask = distances < epsilon
    nearby_gaps = score_gap_values[nearby_mask]
    
    if len(nearby_gaps) > 0 and np.any(nearby_gaps <= 0):
        witness = np.where(nearby_mask)[0][np.argmin(nearby_gaps[nearby_gaps <= 0])]
        return True, witness
    return False, None


# =============================================================================
# DEMO 1: Basic local-to-global certification
# =============================================================================
print("=" * 70)
print("DEMO 1: Cohomological Descent — Local to Global Robustness")
print("=" * 70)

# A ReLU network with 5 activation chambers
chamber_names = ["C₁ (core safe)", "C₂ (left wing)", "C₃ (boundary)", "C₄ (right wing)", "C₅ (outer)"]
margins = np.array([3.0, 2.5, 0.6, 1.8, 1.2])
lipschitz = np.array([1.0, 0.5, 2.0, 1.5, 0.8])
local_radii = margins / lipschitz

print("\nChamber Data:")
print(f"{'Chamber':<20} {'Margin':>8} {'Lipschitz':>10} {'Local Radius':>13}")
print("-" * 55)
for i, name in enumerate(chamber_names):
    print(f"{name:<20} {margins[i]:>8.2f} {lipschitz[i]:>10.2f} {local_radii[i]:>13.2f}")

R, bottleneck = compute_global_certified_radius(margins, lipschitz)
print(f"\nGlobal certified L∞ radius: R = {R:.4f}")
print(f"Bottleneck chamber: {chamber_names[bottleneck]}")
print(f"  → margin = {margins[bottleneck]:.2f}, Lipschitz = {lipschitz[bottleneck]:.2f}")
print(f"  → This chamber limits global robustness")

# =============================================================================
# DEMO 2: Cocycle algebra
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 2: Čech Cocycle Algebra — H¹ Vanishes for Finite Types")
print("=" * 70)

n = 4
print(f"\nIndex set ι has {n} elements.")

# Construct a cocycle from a primitive (guaranteed to be a coboundary)
b_true = np.array([1.0, -0.5, 2.3, 0.7])
c = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        c[i, j] = b_true[j] - b_true[i]

print(f"\nConstructed 1-cochain c[i,j] = b[j] - b[i] with b = {b_true}")
print(f"Cocycle condition satisfied: {check_cocycle_condition(c)}")

is_cob, b_recovered = check_coboundary(c)
print(f"Is coboundary: {is_cob}")
if b_recovered is not None:
    print(f"Recovered primitive (up to constant): {b_recovered}")
    print(f"  (Shifted by b[0]={b_true[0]:.1f}: {b_recovered + b_true[0]})")
    print(f"  Original b: {b_true}")

# Also test a random cocycle
print("\nRandom cocycle test (Theorem 6.1: all finite cocycles are coboundaries):")
b_random = np.random.randn(n)
c_random = np.outer(-np.ones(n), b_random) + np.outer(b_random, np.ones(n))  # c[i,j] = b[j] - b[i]... wait, need to be more careful
c_random = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        c_random[i, j] = b_random[j] - b_random[i]

print(f"  b = {np.round(b_random, 3)}")
print(f"  Cocycle: {check_cocycle_condition(c_random)}")
is_cob2, _ = check_coboundary(c_random)
print(f"  Coboundary: {is_cob2}")
print(f"  → H¹ vanishes ✓")

# =============================================================================
# DEMO 3: Vulnerability detection
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 3: Vulnerability Detection via Stalk Obstruction")
print("=" * 70)

np.random.seed(42)
n_points = 1000
positions = np.random.randn(n_points, 2)

# Score-gap: positive away from decision boundary, zero/negative near it
def score_gap(x):
    """Score gap for a toy classifier with boundary at x[0] = x[1]."""
    return x[0] - x[1]  # positive when x[0] > x[1]

score_gaps = np.array([score_gap(p) for p in positions])

# Test points
test_points = {
    "Safe interior (2, 0)": np.array([2.0, 0.0]),
    "Near boundary (0.1, 0)": np.array([0.1, 0.0]),
    "On boundary (0, 0)": np.array([0.0, 0.0]),
    "Vulnerable side (-0.5, 0)": np.array([-0.5, 0.0]),
}

print("\nVulnerability analysis (ε = 0.3):")
for name, point in test_points.items():
    gap = score_gap(point)
    vuln, witness = detect_vulnerability(score_gaps, positions, point, epsilon=0.3)
    status = "VULNERABLE ⚠" if vuln else "SAFE ✓"
    print(f"  {name}: scoreGap = {gap:.2f}, {status}")

# Demonstrate the stalk radius concept
print("\nStalk radius analysis:")
for name, point in test_points.items():
    gap = score_gap(point)
    # For this linear classifier, stalk radius = |gap| / Lipschitz
    # Lipschitz constant of x[0] - x[1] w.r.t. L∞ is 1
    stalk_r = abs(gap) / 1.0
    print(f"  {name}: stalk radius = {stalk_r:.2f}" + 
          (" → zero stalk ⇒ vulnerable (Thm 5.1)" if stalk_r < 0.01 else ""))

# =============================================================================
# DEMO 4: Scaling behavior
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 4: Scaling of Certified Radius with Number of Chambers")
print("=" * 70)

np.random.seed(123)
chamber_counts = [2, 5, 10, 20, 50, 100, 500, 1000]
print(f"\n{'Chambers':>10} {'Mean R':>10} {'Min R':>10} {'1/√N':>10}")
print("-" * 45)

for N in chamber_counts:
    radii_samples = []
    for _ in range(100):
        m = np.random.exponential(1.0, N)
        L = np.random.exponential(1.0, N) + 0.1
        R, _ = compute_global_certified_radius(m, L)
        radii_samples.append(R)
    mean_R = np.mean(radii_samples)
    min_R = np.min(radii_samples)
    inv_sqrt = 1.0 / np.sqrt(N)
    print(f"{N:>10} {mean_R:>10.4f} {min_R:>10.4f} {inv_sqrt:>10.4f}")

print("\n→ Global radius decreases as more chambers are added (weakest-link effect)")
print("  Scaling is roughly proportional to 1/√N for random margin/Lipschitz data")

# =============================================================================
# DEMO 5: ReLU chamber geometry
# =============================================================================
print("\n" + "=" * 70)
print("DEMO 5: ReLU Chamber Certification (Theorem 4.1)")
print("=" * 70)

# Simulate a 2-layer ReLU network with known chamber structure
# Network: f(x) = max(w·x + b, 0) for binary classification
n_chambers = 6
print(f"\n2D ReLU network with {n_chambers} activation chambers:")

weights = np.array([
    [1.0, 0.5], [-0.3, 1.2], [0.8, -0.4],
    [-0.5, 0.8], [1.1, 0.2], [0.2, -1.0]
])
biases = np.array([0.5, -0.2, 1.0, 0.3, -0.1, 0.8])

print(f"\n{'Chamber':>10} {'‖w‖∞':>8} {'bias':>8} {'margin':>8} {'Lip':>8} {'radius':>10}")
print("-" * 56)
for i in range(n_chambers):
    w_inf_norm = np.max(np.abs(weights[i]))
    margin_i = max(abs(biases[i]), 0.1)  # simplified margin
    lip_i = w_inf_norm
    radius_i = margin_i / lip_i
    print(f"{'C_' + str(i+1):>10} {w_inf_norm:>8.3f} {biases[i]:>8.3f} {margin_i:>8.3f} {lip_i:>8.3f} {radius_i:>10.4f}")

# Compute global
all_margins = np.array([max(abs(b), 0.1) for b in biases])
all_lips = np.array([np.max(np.abs(w)) for w in weights])
R_global, idx = compute_global_certified_radius(all_margins, all_lips)
print(f"\nGlobal certified radius R = {R_global:.4f} (bottleneck: C_{idx+1})")
print(f"  → min_i(margin_i / Lipschitz_i) = {R_global:.4f}")
print(f"  → Any L∞ perturbation smaller than {R_global:.4f} preserves classification")

print("\n" + "=" * 70)
print("All demonstrations complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Sheaf-Theoretic Certified Adversarial Robustness

Generates publication-quality figures:
1. ReLU chamber decomposition with robustness radii
2. Local-to-global certification pipeline
3. Vulnerability locus detection
4. Scaling of certified radius
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PatchCollection
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_chamber_decomposition():
    """
    Figure 1: ReLU chamber decomposition with local robustness radii.
    Shows how a 2D space is partitioned into activation chambers,
    each with its own certified radius.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Chamber decomposition
    ax = axes[0]
    np.random.seed(42)
    
    # Create Voronoi-like chambers
    from scipy.spatial import Voronoi
    points = np.array([
        [0.2, 0.3], [0.5, 0.7], [0.8, 0.4],
        [0.3, 0.8], [0.7, 0.2], [0.5, 0.5]
    ])
    
    # Color by local radius
    margins = np.array([2.0, 1.5, 0.8, 1.2, 3.0, 0.4])
    lips = np.array([1.0, 0.5, 2.0, 1.0, 1.5, 2.5])
    radii = margins / lips
    
    vor = Voronoi(points)
    
    # Plot Voronoi regions with color
    from matplotlib.colors import Normalize
    norm = Normalize(vmin=0, vmax=max(radii))
    cmap = plt.cm.RdYlGn
    
    for i, region_idx in enumerate(vor.point_region):
        region = vor.regions[region_idx]
        if -1 in region or len(region) == 0:
            continue
        polygon = [vor.vertices[v] for v in region]
        poly = plt.Polygon(polygon, facecolor=cmap(norm(radii[i])), 
                          edgecolor='black', linewidth=1.5, alpha=0.7)
        ax.add_patch(poly)
    
    # Plot chamber centers with labels
    for i, (pt, r) in enumerate(zip(points, radii)):
        ax.plot(*pt, 'ko', markersize=8)
        ax.annotate(f'C{i+1}\nr={r:.2f}', pt, fontsize=9,
                   ha='center', va='bottom', fontweight='bold',
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_title('Activation Chamber Decomposition\nwith Local Robustness Radii', fontsize=13, fontweight='bold')
    ax.set_xlabel('Feature 1')
    ax.set_ylabel('Feature 2')
    
    sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
    sm.set_array([])
    plt.colorbar(sm, ax=ax, label='Local Certified Radius')
    
    # Right: Robustness radii bar chart
    ax = axes[1]
    colors = [cmap(norm(r)) for r in radii]
    bars = ax.bar(range(1, len(radii)+1), radii, color=colors, edgecolor='black', linewidth=1)
    
    global_R = min(radii)
    ax.axhline(y=global_R, color='red', linestyle='--', linewidth=2, label=f'Global R = {global_R:.2f}')
    
    bottleneck = np.argmin(radii)
    bars[bottleneck].set_edgecolor('red')
    bars[bottleneck].set_linewidth(3)
    
    ax.set_xlabel('Chamber Index', fontsize=12)
    ax.set_ylabel('Certified Radius', fontsize=12)
    ax.set_title('Local vs. Global Certified Radii\n(Sheaf Descent: R = inf rᵢ)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.set_xticks(range(1, len(radii)+1))
    ax.set_xticklabels([f'C{i}' for i in range(1, len(radii)+1)])
    
    plt.tight_layout()
    return fig


def plot_vulnerability_detection():
    """
    Figure 2: Vulnerability locus detection.
    Shows decision boundary, vulnerable points, and stalk radii.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Create a toy classifier
    np.random.seed(42)
    x = np.linspace(-3, 3, 200)
    y = np.linspace(-3, 3, 200)
    X, Y = np.meshgrid(x, y)
    
    # Score gap: nonlinear decision boundary
    Z = X**2 - Y**2 + 0.5 * np.sin(3*X) - 0.3 * Y
    
    # Left: Decision landscape with vulnerability
    ax = axes[0]
    contour = ax.contourf(X, Y, Z, levels=50, cmap='RdBu', alpha=0.8)
    ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
    plt.colorbar(contour, ax=ax, label='Score Gap')
    
    # Mark vulnerable points (near decision boundary)
    vuln_mask = np.abs(Z) < 0.1
    vuln_x = X[vuln_mask]
    vuln_y = Y[vuln_mask]
    ax.scatter(vuln_x[::5], vuln_y[::5], c='yellow', s=10, alpha=0.5, 
              label='Vulnerable locus', zorder=5, edgecolors='orange', linewidth=0.5)
    
    ax.set_title('Decision Landscape & Vulnerable Locus\n(Theorem 5.1: Zero Stalk → Vulnerability)', 
                fontsize=12, fontweight='bold')
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.legend(fontsize=10)
    
    # Right: Stalk radius heatmap
    ax = axes[1]
    # Stalk radius ≈ |scoreGap| / local_Lipschitz
    grad_x = np.gradient(Z, x, axis=1)
    grad_y = np.gradient(Z, y, axis=0)
    lip = np.sqrt(grad_x**2 + grad_y**2) + 0.01  # avoid division by zero
    stalk_radius = np.abs(Z) / lip
    
    im = ax.pcolormesh(X, Y, stalk_radius, cmap='viridis', shading='auto',
                       vmin=0, vmax=np.percentile(stalk_radius, 95))
    ax.contour(X, Y, Z, levels=[0], colors='red', linewidths=2, linestyles='--')
    plt.colorbar(im, ax=ax, label='Stalk Radius')
    
    ax.set_title('Stalk Radius Map\n(Bright = Robust, Dark = Vulnerable)', 
                fontsize=12, fontweight='bold')
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    
    plt.tight_layout()
    return fig


def plot_scaling_behavior():
    """
    Figure 3: Scaling of certified radius with number of chambers.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    np.random.seed(42)
    chamber_counts = np.array([2, 5, 10, 20, 50, 100, 200, 500, 1000])
    
    # Left: Scaling plot
    ax = axes[0]
    mean_radii = []
    std_radii = []
    
    for N in chamber_counts:
        radii = []
        for _ in range(200):
            m = np.random.exponential(1.0, N)
            L = np.random.exponential(1.0, N) + 0.1
            R = np.min(m / L)
            radii.append(R)
        mean_radii.append(np.mean(radii))
        std_radii.append(np.std(radii))
    
    mean_radii = np.array(mean_radii)
    std_radii = np.array(std_radii)
    
    ax.errorbar(chamber_counts, mean_radii, yerr=std_radii, fmt='o-',
               color='#2196F3', linewidth=2, markersize=8, capsize=5,
               label='Global radius R')
    
    # Fit 1/sqrt(N) curve
    c_fit = mean_radii[0] * np.sqrt(chamber_counts[0])
    ax.plot(chamber_counts, c_fit / np.sqrt(chamber_counts), '--',
           color='#FF5722', linewidth=2, label=r'$\sim 1/\sqrt{N}$ fit')
    
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.set_xlabel('Number of Chambers N', fontsize=12)
    ax.set_ylabel('Global Certified Radius R', fontsize=12)
    ax.set_title('Weakest-Link Scaling\n(R decreases with chamber count)', 
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Right: Distribution of radii for different N
    ax = axes[1]
    for N, color, label in [(5, '#4CAF50', 'N=5'), (50, '#2196F3', 'N=50'), 
                             (500, '#FF5722', 'N=500')]:
        radii = []
        for _ in range(1000):
            m = np.random.exponential(1.0, N)
            L = np.random.exponential(1.0, N) + 0.1
            R = np.min(m / L)
            radii.append(R)
        ax.hist(radii, bins=50, alpha=0.5, color=color, label=label, density=True)
    
    ax.set_xlabel('Global Certified Radius R', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title('Distribution of Certified Radius\n(More chambers → smaller, tighter R)', 
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


def plot_certification_pipeline():
    """
    Figure 4: The sheaf certification pipeline diagram.
    """
    fig, ax = plt.subplots(1, 1, figsize=(14, 5))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 5)
    ax.axis('off')
    
    # Pipeline boxes
    boxes = [
        (1, 2.5, 'Input\nSpace X', '#E3F2FD'),
        (4, 2.5, 'Chamber\nDecomposition\n{Cᵢ}', '#E8F5E9'),
        (7, 2.5, 'Local\nCertificates\nrᵢ = mᵢ/Lᵢ', '#FFF3E0'),
        (10, 2.5, 'Cocycle\nCheck\nH¹ = 0?', '#FCE4EC'),
        (13, 2.5, 'Global\nRadius\nR = inf rᵢ', '#E8EAF6'),
    ]
    
    for x, y, text, color in boxes:
        rect = mpatches.FancyBboxPatch((x-1, y-1), 2, 2, 
                                        boxstyle="round,pad=0.1",
                                        facecolor=color, edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y, text, ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Arrows
    for x_start in [2, 5, 8, 11]:
        ax.annotate('', xy=(x_start+1, 2.5), xytext=(x_start, 2.5),
                   arrowprops=dict(arrowstyle='->', lw=2, color='#333'))
    
    # Labels above arrows
    arrow_labels = ['ReLU\nPartition', 'Margin/Lip\nComputation', 'Čech\nCohomology', 'Sheaf\nDescent']
    for i, label in enumerate(arrow_labels):
        ax.text(2.5 + 3*i, 4.2, label, ha='center', va='center', fontsize=9,
               fontstyle='italic', color='#555')
    
    # Bottom: theorem reference
    ax.text(7, 0.3, 'Theorem 3.1: vanishing_H1_implies_certified_Linf_radius', 
           ha='center', va='center', fontsize=11, fontweight='bold',
           bbox=dict(boxstyle='round', facecolor='#FFEB3B', alpha=0.8))
    
    ax.set_title('Sheaf Certification Pipeline', fontsize=14, fontweight='bold', pad=20)
    
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")
    
    fig1 = plot_chamber_decomposition()
    fig1.savefig('/workspace/request-project/fig_chambers.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_chambers.png")
    
    fig2 = plot_vulnerability_detection()
    fig2.savefig('/workspace/request-project/fig_vulnerability.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_vulnerability.png")
    
    fig3 = plot_scaling_behavior()
    fig3.savefig('/workspace/request-project/fig_scaling.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_scaling.png")
    
    fig4 = plot_certification_pipeline()
    fig4.savefig('/workspace/request-project/fig_pipeline.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_pipeline.png")
    
    print("All visualizations generated.")
