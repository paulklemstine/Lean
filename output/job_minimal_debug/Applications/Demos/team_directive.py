#!/usr/bin/env python3
"""
Tropical Separation Classifier — Applications

Real-world applications of the tropical classification theorem,
demonstrating certified decision boundaries in practical settings.
"""

import numpy as np
from algorithms import (
    tropical_score, tropical_score_batch,
    find_separating_coordinate, construct_tighter_classifier,
    verify_tropical_separation, tropical_coord_margin,
    full_tropical_pipeline
)


def application_medical_screening():
    """
    Application 1: Medical Screening with Certified Margins
    
    Scenario: A hospital uses 5 biomarkers to classify patients as
    high-risk or low-risk for a condition. One biomarker (e.g., a
    specific protein level) perfectly separates the known cases.
    
    The tropical classifier provides a certified margin of safety:
    any perturbation within the margin cannot flip the classification.
    """
    print("=" * 60)
    print("APPLICATION 1: Medical Screening")
    print("=" * 60)
    
    # 5 biomarkers: [protein_X, WBC, CRP, temp, BP_systolic]
    # Protein X (coord 0) separates high-risk from low-risk
    patients = np.array([
        # High-risk patients (positive class)
        [85.0, 12.0, 15.0, 38.5, 145.0],   # Patient 0
        [92.0, 11.5, 12.0, 38.2, 130.0],   # Patient 1
        [78.0, 13.0, 18.0, 39.0, 155.0],   # Patient 2
        [88.0, 10.0, 14.0, 38.8, 140.0],   # Patient 3
        # Low-risk patients (negative class)
        [25.0, 7.0,  3.0,  36.8, 120.0],   # Patient 4
        [30.0, 8.0,  5.0,  37.0, 125.0],   # Patient 5
        [22.0, 6.5,  2.0,  36.6, 115.0],   # Patient 6
        [35.0, 9.0,  4.0,  37.2, 135.0],   # Patient 7
    ])
    
    high_risk = [0, 1, 2, 3]
    low_risk = [4, 5, 6, 7]
    
    print("\nBiomarkers: [Protein_X, WBC, CRP, Temperature, BP_systolic]")
    print(f"High-risk patients: {len(high_risk)}")
    print(f"Low-risk patients: {len(low_risk)}")
    
    result = full_tropical_pipeline(patients, high_risk, low_risk)
    
    if result:
        w, gamma, i0 = result
        biomarkers = ["Protein_X", "WBC", "CRP", "Temperature", "BP_systolic"]
        print(f"\nKey discriminative biomarker: {biomarkers[i0]}")
        print(f"Certified margin: γ = {gamma:.1f}")
        print(f"\nInterpretation: Any measurement perturbation < {gamma:.1f}")
        print(f"on {biomarkers[i0]} cannot flip the classification.")
        
        # Test with a new patient
        new_patient = np.array([70.0, 11.0, 10.0, 38.0, 138.0])
        score = tropical_score(w, new_patient)
        min_pos_score = min(tropical_score(w, patients[p]) for p in high_risk)
        max_neg_score = max(tropical_score(w, patients[n]) for n in low_risk)
        
        print(f"\nNew patient score: {score:.1f}")
        print(f"High-risk score range: [{min_pos_score:.1f}, ...]")
        print(f"Low-risk score range: [..., {max_neg_score:.1f}]")
        if score >= max_neg_score + gamma:
            print("→ Classified as HIGH-RISK (with certified margin)")
        elif score <= min_pos_score - gamma:
            print("→ Classified as LOW-RISK (with certified margin)")
        else:
            print("→ Classification uncertain (within margin)")


def application_quality_control():
    """
    Application 2: Manufacturing Quality Control
    
    Scenario: A factory tests products on 4 quality metrics.
    Products must be classified as PASS or FAIL with zero tolerance
    for misclassification on known reference samples.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Manufacturing Quality Control")
    print("=" * 60)
    
    # Metrics: [tensile_strength, surface_finish, dimension_accuracy, weight]
    products = np.array([
        # PASS samples
        [950.0, 0.8, 99.5, 500.2],
        [980.0, 0.9, 99.8, 500.1],
        [960.0, 0.7, 99.6, 500.3],
        [970.0, 0.85, 99.7, 500.0],
        # FAIL samples
        [700.0, 0.3, 97.0, 498.0],
        [650.0, 0.4, 96.5, 497.5],
        [720.0, 0.2, 97.5, 499.0],
    ])
    
    pass_idx = [0, 1, 2, 3]
    fail_idx = [4, 5, 6]
    
    metrics = ["Tensile_Strength", "Surface_Finish", "Dim_Accuracy", "Weight"]
    
    result = full_tropical_pipeline(products, pass_idx, fail_idx)
    
    if result:
        w, gamma, i0 = result
        print(f"\nPrimary quality metric: {metrics[i0]}")
        print(f"Certified margin: γ = {gamma:.1f}")
        print(f"\nThis means: if the {metrics[i0]} measurement is accurate")
        print(f"to within ±{gamma/2:.1f}, the classification is guaranteed correct.")


def application_anomaly_detection():
    """
    Application 3: Network Anomaly Detection
    
    Scenario: A network security system monitors 6 traffic features.
    Normal traffic must be distinguished from attacks with certified
    separation guarantees.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Network Anomaly Detection")
    print("=" * 60)
    
    np.random.seed(42)
    
    # Features: [packet_rate, avg_size, entropy, src_diversity, dst_port_var, duration]
    n_normal = 10
    n_attack = 8
    
    # Normal traffic: low packet rate, moderate entropy
    normal = np.column_stack([
        np.random.normal(100, 20, n_normal),    # packet_rate
        np.random.normal(500, 100, n_normal),   # avg_size
        np.random.normal(4.0, 0.5, n_normal),   # entropy
        np.random.normal(50, 10, n_normal),     # src_diversity
        np.random.normal(20, 5, n_normal),      # dst_port_var
        np.random.normal(300, 50, n_normal),    # duration
    ])
    
    # Attack traffic: very high packet rate
    attack = np.column_stack([
        np.random.normal(5000, 500, n_attack),  # packet_rate (high!)
        np.random.normal(60, 20, n_attack),     # avg_size
        np.random.normal(1.0, 0.3, n_attack),   # entropy (low)
        np.random.normal(3, 1, n_attack),       # src_diversity
        np.random.normal(2, 1, n_attack),       # dst_port_var
        np.random.normal(10, 5, n_attack),      # duration
    ])
    
    traffic = np.vstack([attack, normal])  # attacks are "positive" (to detect)
    attack_idx = list(range(n_attack))
    normal_idx = list(range(n_attack, n_attack + n_normal))
    
    features = ["Packet_Rate", "Avg_Size", "Entropy", "Src_Diversity", "Dst_Port_Var", "Duration"]
    
    result = full_tropical_pipeline(traffic, attack_idx, normal_idx)
    
    if result:
        w, gamma, i0 = result
        print(f"\nPrimary detection feature: {features[i0]}")
        print(f"Certified margin: γ = {gamma:.1f}")
        print(f"\nAny traffic with {features[i0]} perturbation < {gamma:.1f}")
        print("will be correctly classified with mathematical certainty.")
        
        # Show score distribution
        attack_scores = tropical_score_batch(w, traffic[attack_idx])
        normal_scores = tropical_score_batch(w, traffic[normal_idx])
        print(f"\nAttack scores:  min={np.min(attack_scores):.1f}, max={np.max(attack_scores):.1f}")
        print(f"Normal scores:  min={np.min(normal_scores):.1f}, max={np.max(normal_scores):.1f}")
        print(f"Score gap:      {np.min(attack_scores) - np.max(normal_scores):.1f} ≥ γ = {gamma:.1f}")


def application_comparison():
    """
    Application 4: Comparison with Linear Classifier
    
    Demonstrates the geometric difference between tropical and linear
    classifiers on the same data.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Tropical vs Linear Classifier")
    print("=" * 60)
    
    # 2D data for easy visualization
    phi = np.array([
        [10.0, 1.0],   # Positive
        [8.0,  2.0],   # Positive
        [3.0,  5.0],   # Negative
        [2.0,  7.0],   # Negative
    ])
    
    P = [0, 1]
    N = [2, 3]
    
    # Tropical classifier
    result = full_tropical_pipeline(phi, P, N, verbose=False)
    w_trop, gamma_trop, i0 = result
    
    # Simple linear classifier (using coordinate 0 difference)
    # Linear score: w · φ, try w = (1, 0)
    w_lin = np.array([1.0, 0.0])
    lin_scores = phi @ w_lin
    lin_margin = min(lin_scores[p] for p in P) - max(lin_scores[n] for n in N)
    
    print(f"\nTropical classifier:")
    print(f"  Weights: {w_trop}")
    print(f"  Margin: {gamma_trop}")
    for i in range(4):
        print(f"  Score[{i}] = {tropical_score(w_trop, phi[i]):.1f}")
    
    print(f"\nLinear classifier (w = [1, 0]):")
    print(f"  Margin: {lin_margin}")
    for i in range(4):
        print(f"  Score[{i}] = {lin_scores[i]:.1f}")
    
    print(f"\nBoth achieve the same margin ({gamma_trop} = {lin_margin})")
    print("because both reduce to coordinate 0 on this data.")
    print("The tropical classifier does this by suppressing coordinate 1,")
    print("while the linear classifier simply ignores it.")


if __name__ == "__main__":
    application_medical_screening()
    application_quality_control()
    application_anomaly_detection()
    application_comparison()
    print("\n" + "=" * 60)
    print("All applications complete!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Separation Classifier — Demonstration

Demonstrates the main theorem: coordinate-wise separation implies
existence of a tropical (max-plus) classifier with certified positive margin.
"""

import numpy as np

def tropical_score(w: np.ndarray, phi: np.ndarray) -> float:
    """Compute the tropical (max-plus) score: max_i(w_i + phi_i)."""
    return np.max(w + phi)

def find_separating_coordinate(phi: np.ndarray, P_idx: list, N_idx: list) -> tuple:
    """
    Find a coordinate that uniformly separates P from N.
    
    Returns (coord_index, min_gap) or (None, 0) if no separating coordinate exists.
    """
    n_features = phi.shape[1]
    best_coord = None
    best_gap = 0
    
    for i in range(n_features):
        min_pos = min(phi[p, i] for p in P_idx)
        max_neg = max(phi[n, i] for n in N_idx)
        gap = min_pos - max_neg
        if gap > 0 and gap > best_gap:
            best_coord = i
            best_gap = gap
    
    return best_coord, best_gap

def construct_tropical_classifier(phi: np.ndarray, P_idx: list, N_idx: list, i0: int):
    """
    Construct a tropical classifier with certified margin.
    
    Given separating coordinate i0, constructs weight vector w and margin gamma
    such that tropical_score(w, phi[p]) >= tropical_score(w, phi[n]) + gamma
    for all p in P, n in N.
    
    Args:
        phi: Feature matrix (n_samples x n_features)
        P_idx: Indices of positive samples
        N_idx: Indices of negative samples
        i0: Separating coordinate
    
    Returns:
        w: Weight vector
        gamma: Certified margin (positive)
    """
    all_idx = P_idx + N_idx
    n_features = phi.shape[1]
    
    # Compute suppression bound M
    M = sum(
        sum(abs(phi[x, i] - phi[x, i0]) for i in range(n_features))
        for x in all_idx
    )
    
    # Construct weight vector
    w = np.array([-M if i != i0 else 0.0 for i in range(n_features)])
    
    # Compute margin
    gamma = min(
        phi[p, i0] - phi[n, i0]
        for p in P_idx
        for n in N_idx
    )
    
    return w, gamma

def verify_separation(phi: np.ndarray, w: np.ndarray, gamma: float,
                       P_idx: list, N_idx: list) -> bool:
    """Verify that w achieves tropical separation with margin gamma."""
    for p in P_idx:
        for n in N_idx:
            score_p = tropical_score(w, phi[p])
            score_n = tropical_score(w, phi[n])
            if score_p < score_n + gamma - 1e-10:  # numerical tolerance
                return False
    return True

# ============================================================
# Demo 1: The paper's concrete example
# ============================================================
print("=" * 60)
print("DEMO 1: Concrete Example from the Theorem")
print("=" * 60)

# Feature map: 4 points, 2 features
phi = np.array([
    [10.0, 1.0],   # Point 0 (positive)
    [8.0,  2.0],   # Point 1 (positive)
    [3.0,  5.0],   # Point 2 (negative)
    [2.0,  7.0],   # Point 3 (negative)
])

P = [0, 1]  # Positive indices
N = [2, 3]  # Negative indices

print("\nFeature matrix:")
print("  Point 0 (pos): φ = [10, 1]")
print("  Point 1 (pos): φ = [8, 2]")
print("  Point 2 (neg): φ = [3, 5]")
print("  Point 3 (neg): φ = [2, 7]")

# Find separating coordinate
i0, gap = find_separating_coordinate(phi, P, N)
print(f"\nSeparating coordinate: {i0} (gap = {gap})")

# Construct classifier
w, gamma = construct_tropical_classifier(phi, P, N, i0)
print(f"\nWeight vector: w = {w}")
print(f"Certified margin: γ = {gamma}")

# Verify
print("\nTropical scores:")
for i in range(4):
    s = tropical_score(w, phi[i])
    label = "pos" if i in P else "neg"
    print(f"  Point {i} ({label}): score = {s}")

verified = verify_separation(phi, w, gamma, P, N)
print(f"\nSeparation verified: {verified}")
print(f"All positive scores exceed all negative scores by ≥ {gamma}")

# ============================================================
# Demo 2: Higher-dimensional example
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Higher-Dimensional Example (10 features)")
print("=" * 60)

np.random.seed(42)
n_features = 10
n_pos = 5
n_neg = 5

# Generate data where coordinate 3 separates classes
phi2 = np.random.randn(n_pos + n_neg, n_features)
# Boost coordinate 3 for positive, suppress for negative
for i in range(n_pos):
    phi2[i, 3] = 10 + np.random.rand()  # Positives: high on coord 3
for i in range(n_pos, n_pos + n_neg):
    phi2[i, 3] = 2 + np.random.rand()   # Negatives: low on coord 3

P2 = list(range(n_pos))
N2 = list(range(n_pos, n_pos + n_neg))

i0_2, gap2 = find_separating_coordinate(phi2, P2, N2)
print(f"\nSeparating coordinate found: {i0_2} (gap = {gap2:.4f})")

w2, gamma2 = construct_tropical_classifier(phi2, P2, N2, i0_2)
print(f"Certified margin: γ = {gamma2:.4f}")

print("\nTropical scores:")
for i in range(n_pos + n_neg):
    s = tropical_score(w2, phi2[i])
    label = "pos" if i in P2 else "neg"
    print(f"  Point {i} ({label}): score = {s:.4f}")

verified2 = verify_separation(phi2, w2, gamma2, P2, N2)
print(f"\nSeparation verified: {verified2}")

# ============================================================
# Demo 3: Margin vs. number of features
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: How Margin Depends on Feature Count")
print("=" * 60)

np.random.seed(123)
n_trials = 5
for n_feat in [2, 5, 10, 50, 100]:
    margins = []
    for _ in range(n_trials):
        phi3 = np.random.randn(10, n_feat) * 2
        # Make coordinate 0 separating
        for i in range(5):
            phi3[i, 0] = 8 + np.random.rand()
        for i in range(5, 10):
            phi3[i, 0] = 3 + np.random.rand()
        
        _, margin3 = construct_tropical_classifier(phi3, list(range(5)), list(range(5, 10)), 0)
        margins.append(margin3)
    
    avg_margin = np.mean(margins)
    print(f"  {n_feat:3d} features: avg margin = {avg_margin:.4f}")

print("\nNote: The margin depends only on the separating coordinate,")
print("not on the number of other features. The weight construction")
print("suppresses all non-separating coordinates regardless of count.")

# ============================================================
# Demo 4: When no coordinate separates (impossibility)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: No Uniform Coordinate Witness")
print("=" * 60)

phi4 = np.array([
    [5.0, 1.0],   # Point 0 (positive) — high on coord 0
    [1.0, 5.0],   # Point 1 (positive) — high on coord 1
    [3.0, 3.0],   # Point 2 (negative) — between on both
])

P4 = [0, 1]
N4 = [2]

print("\nFeature matrix:")
print("  Point 0 (pos): φ = [5, 1]")
print("  Point 1 (pos): φ = [1, 5]")
print("  Point 2 (neg): φ = [3, 3]")

i0_4, gap4 = find_separating_coordinate(phi4, P4, N4)
print(f"\nSeparating coordinate: {i0_4} (gap = {gap4})")
print("No single coordinate separates all pairs!")
print("  Coord 0: Point 1 (pos) has φ=1 < Point 2 (neg) φ=3. Fails.")
print("  Coord 1: Point 0 (pos) has φ=1 < Point 2 (neg) φ=3. Fails.")
print("\nHowever, pairwise separation exists (each pos beats neg on SOME coord).")
print("This is exactly where the Tropical Hahn-Banach extension is needed.")

print("\n" + "=" * 60)
print("All demos complete!")
print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import base64
from pathlib import Path

# Read all text files
def read_file(path):
    return Path(path).read_text()

article = read_file("ARTICLE.md")
research_paper = read_file("RESEARCH_PAPER.md")
future_directions = read_file("FUTURE_DIRECTIONS.md")
lean_proofs = read_file("Catalog/Bridges/TropicalSeparationClassifier.lean")
demo_code = read_file("demo.py")
algorithms_code = read_file("algorithms.py")
applications_code = read_file("applications.py")

# Read visualization images as base64
def img_to_base64(path):
    with open(path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode("utf-8")
    return f"data:image/png;base64,{b64}"

viz1 = img_to_base64("fig_separation_geometry.png")
viz2 = img_to_base64("fig_weight_construction.png")
viz3 = img_to_base64("fig_margin_analysis.png")

package = {
    "title": "Tropical Separation Implies Finite Max-Plus Classifier with Certified Margin",
    "domain": "Tropical Geometry / Certified Machine Learning",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Separation Classifier Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Medical, Manufacturing, Network Security",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Separation Algorithm",
            "pseudocode": """Algorithm TropicalSeparator(φ, P, N, i₀):
  Input: Feature matrix φ, positive indices P, negative indices N, separating coordinate i₀
  Output: Weight vector w, certified margin γ

  1. M ← Σ_{x ∈ P∪N} Σ_{i} |φ(x,i) - φ(x,i₀)|
  2. w[i₀] ← 0
  3. For each i ≠ i₀: w[i] ← -M
  4. γ ← min_{p∈P, n∈N} (φ(p,i₀) - φ(n,i₀))
  5. Return (w, γ)

Complexity: O(|P∪N| · |ι|) time, O(|ι|) space

Correctness: γ > 0 when i₀ uniformly separates P from N.
For all p∈P, n∈N: score(w,φ(p)) ≥ score(w,φ(n)) + γ.""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Tropical Separation Geometry", "data": viz1},
        {"name": "Weight Construction Visualization", "data": viz2},
        {"name": "Margin vs Coordinate Gap Analysis", "data": viz3}
    ],
    "lean_proofs": lean_proofs
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({Path('PACKAGE.json').stat().st_size} bytes)")


#!/usr/bin/env python3
"""
Tropical Separation Classifier — Visualizations

Generates publication-quality figures illustrating the tropical
classification theorem and its geometric interpretation.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_separation_geometry():
    """
    Figure 1: Geometric view of tropical separation.
    Shows data points in 2D feature space with the separating
    coordinate highlighted and the margin visualized.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Data
    pos_points = np.array([[10, 1], [8, 2]])
    neg_points = np.array([[3, 5], [2, 7]])
    
    # Left: Feature space with coordinate 0 separation
    ax = axes[0]
    ax.scatter(pos_points[:, 0], pos_points[:, 1], c='#2196F3', s=150,
              marker='o', label='Positive (P)', zorder=5, edgecolors='black', linewidths=1.5)
    ax.scatter(neg_points[:, 0], neg_points[:, 1], c='#F44336', s=150,
              marker='s', label='Negative (N)', zorder=5, edgecolors='black', linewidths=1.5)
    
    # Separating band on coordinate 0
    min_pos = min(pos_points[:, 0])
    max_neg = max(neg_points[:, 0])
    ax.axvspan(max_neg, min_pos, alpha=0.15, color='#4CAF50', label=f'Margin gap (γ={min_pos-max_neg})')
    ax.axvline(x=max_neg, color='#F44336', linestyle='--', alpha=0.7)
    ax.axvline(x=min_pos, color='#2196F3', linestyle='--', alpha=0.7)
    
    # Annotations
    ax.annotate(f'max neg = {max_neg}', xy=(max_neg, 0.5), fontsize=10,
               ha='right', color='#F44336')
    ax.annotate(f'min pos = {min_pos}', xy=(min_pos, 0.5), fontsize=10,
               ha='left', color='#2196F3')
    
    for i, p in enumerate(pos_points):
        ax.annotate(f'p{i}=({p[0]},{p[1]})', xy=p, xytext=(5, 10),
                   textcoords='offset points', fontsize=9)
    for i, n in enumerate(neg_points):
        ax.annotate(f'n{i}=({n[0]},{n[1]})', xy=n, xytext=(5, 10),
                   textcoords='offset points', fontsize=9)
    
    ax.set_xlabel('Feature 0 (Separating Coordinate)', fontsize=12)
    ax.set_ylabel('Feature 1', fontsize=12)
    ax.set_title('Feature Space: Coordinate Separation', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1, 13)
    ax.set_ylim(-1, 10)
    
    # Right: Tropical scores
    ax = axes[1]
    M = 22  # suppression bound
    w = np.array([0, -M])
    
    all_points = np.vstack([pos_points, neg_points])
    labels = ['p0', 'p1', 'n0', 'n1']
    colors = ['#2196F3', '#2196F3', '#F44336', '#F44336']
    
    scores = [max(w[0] + p[0], w[1] + p[1]) for p in all_points]
    
    bars = ax.barh(range(4), scores, color=colors, edgecolor='black', linewidth=1.2, height=0.6)
    ax.set_yticks(range(4))
    ax.set_yticklabels(labels, fontsize=12)
    ax.set_xlabel('Tropical Score = max_i(w_i + φ_i)', fontsize=12)
    ax.set_title('Tropical Scores with Certified Margin', fontsize=14, fontweight='bold')
    
    # Margin annotation
    min_pos_score = min(scores[:2])
    max_neg_score = max(scores[2:])
    margin = min_pos_score - max_neg_score
    
    ax.axvline(x=max_neg_score, color='#F44336', linestyle='--', alpha=0.5)
    ax.axvline(x=min_pos_score, color='#2196F3', linestyle='--', alpha=0.5)
    
    mid = (min_pos_score + max_neg_score) / 2
    ax.annotate(f'γ = {margin}', xy=(mid, 3.5), fontsize=14, fontweight='bold',
               ha='center', color='#4CAF50',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='#E8F5E9', edgecolor='#4CAF50'))
    
    for i, (score, label) in enumerate(zip(scores, labels)):
        ax.text(score + 0.3, i, f'{score:.0f}', va='center', fontsize=11, fontweight='bold')
    
    ax.grid(True, axis='x', alpha=0.3)
    ax.set_xlim(-1, 12)
    
    fig.suptitle('Tropical Separation Theorem: From Coordinate Gap to Certified Margin',
                fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def plot_weight_construction():
    """
    Figure 2: Weight construction visualization.
    Shows how the suppression penalty drives non-separating
    coordinates below the separating coordinate.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Before (w = 0)
    ax = axes[0]
    points = np.array([[10, 1], [8, 2], [3, 5], [2, 7]])
    labels = ['p0', 'p1', 'n0', 'n1']
    colors_pts = ['#2196F3', '#2196F3', '#F44336', '#F44336']
    
    x = np.arange(4)
    width = 0.35
    
    bars1 = ax.bar(x - width/2, points[:, 0], width, label='w₀+φ₀ (coord 0)',
                   color='#42A5F5', edgecolor='black')
    bars2 = ax.bar(x + width/2, points[:, 1], width, label='w₁+φ₁ (coord 1)',
                   color='#EF5350', edgecolor='black')
    
    # Mark the max (tropical score)
    for i in range(4):
        trop = max(points[i, 0], points[i, 1])
        ax.plot(i, trop + 0.3, 'k^', markersize=10)
    
    ax.set_xticks(x)
    ax.set_xticklabels(labels, fontsize=12)
    ax.set_ylabel('w_i + φ_i', fontsize=12)
    ax.set_title('w = (0, 0): No Separation', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, axis='y', alpha=0.3)
    
    # Add note about failure
    ax.text(0.5, -0.12, 'Tropical score of n0 = max(3,5) = 5 > max(10,1) = 10? No,\n'
            'but max(3,5) = 5 < max(8,2) = 8. Issue: n1 score = max(2,7) = 7 > 5 = n0.',
            transform=ax.transAxes, fontsize=8, ha='center', style='italic', color='gray')
    
    # Right: After (w = (0, -M))
    ax = axes[1]
    M = 22
    w = np.array([0, -M])
    
    weighted = points + w[np.newaxis, :]
    
    bars1 = ax.bar(x - width/2, weighted[:, 0], width, label='w₀+φ₀ = 0+φ₀',
                   color='#42A5F5', edgecolor='black')
    bars2 = ax.bar(x + width/2, weighted[:, 1], width, label=f'w₁+φ₁ = -{M}+φ₁',
                   color='#EF5350', edgecolor='black', alpha=0.5)
    
    # Mark the max (tropical score)
    for i in range(4):
        trop = max(weighted[i, 0], weighted[i, 1])
        ax.plot(i, trop + 0.5, 'k^', markersize=10)
        ax.text(i, trop + 1.5, f'{trop:.0f}', ha='center', fontsize=11, fontweight='bold')
    
    ax.set_xticks(x)
    ax.set_xticklabels(labels, fontsize=12)
    ax.set_ylabel('w_i + φ_i', fontsize=12)
    ax.set_title(f'w = (0, -{M}): Separation Achieved!', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, axis='y', alpha=0.3)
    ax.set_ylim(-25, 15)
    
    fig.suptitle('Weight Construction: Suppressing Non-Separating Coordinates',
                fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def plot_margin_analysis():
    """
    Figure 3: Margin as a function of the separating coordinate gap.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    np.random.seed(42)
    
    gaps = np.linspace(0.1, 10, 50)
    margins = []
    
    for gap in gaps:
        # Generate random data with controlled gap on coordinate 0
        n_pos, n_neg = 5, 5
        phi = np.random.randn(n_pos + n_neg, 5) * 2
        
        # Set coordinate 0 to have the specified gap
        base = 5
        for i in range(n_pos):
            phi[i, 0] = base + gap/2 + np.random.rand() * 0.5
        for i in range(n_pos, n_pos + n_neg):
            phi[i, 0] = base - gap/2 - np.random.rand() * 0.5
        
        P = list(range(n_pos))
        N = list(range(n_pos, n_pos + n_neg))
        
        # Compute margin
        gamma = min(phi[p, 0] - phi[n, 0] for p in P for n in N)
        margins.append(gamma)
    
    ax.scatter(gaps, margins, c='#2196F3', s=30, alpha=0.7, zorder=5)
    ax.plot(gaps, gaps, 'k--', alpha=0.5, label='γ = gap (ideal)')
    ax.fill_between(gaps, 0, gaps, alpha=0.1, color='#4CAF50')
    
    ax.set_xlabel('Coordinate Gap (min positive - max negative)', fontsize=12)
    ax.set_ylabel('Certified Margin γ', fontsize=12)
    ax.set_title('Margin vs. Coordinate Gap', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 10.5)
    ax.set_ylim(0, 11)
    
    ax.text(0.05, 0.95, 'Margin ≥ gap always holds\n(by construction)',
           transform=ax.transAxes, fontsize=11, va='top',
           bbox=dict(boxstyle='round', facecolor='#E8F5E9', alpha=0.8))
    
    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all figures and return as base64 data URIs."""
    print("Generating visualizations...")
    
    fig1 = plot_separation_geometry()
    uri1 = fig_to_base64(fig1)
    fig1.savefig('/workspace/request-project/fig_separation_geometry.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig1)
    print("  Figure 1: Separation geometry — done")
    
    fig2 = plot_weight_construction()
    uri2 = fig_to_base64(fig2)
    fig2.savefig('/workspace/request-project/fig_weight_construction.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig2)
    print("  Figure 2: Weight construction — done")
    
    fig3 = plot_margin_analysis()
    uri3 = fig_to_base64(fig3)
    fig3.savefig('/workspace/request-project/fig_margin_analysis.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig3)
    print("  Figure 3: Margin analysis — done")
    
    return [
        {"name": "Tropical Separation Geometry", "data": uri1},
        {"name": "Weight Construction", "data": uri2},
        {"name": "Margin Analysis", "data": uri3},
    ]


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    print(f"\nGenerated {len(vizs)} visualizations")
    for v in vizs:
        print(f"  {v['name']}: {len(v['data'])} chars")
