"""
Applications of the Tropical Chebyshev Radius Theorem

Demonstrates real-world applications of exact certified robustness
for tropical affine classifiers.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple

# ============================================================================
# Application 1: Adversarial Robustness Certification for Image Classifiers
# ============================================================================

def demo_image_robustness():
    """
    Simulate a tropical affine approximation of an image classifier
    and compute exact certified radii.
    """
    print("=" * 60)
    print("APPLICATION 1: Image Classifier Robustness Certification")
    print("=" * 60)

    np.random.seed(42)

    # Simulate a 10-class classifier on 784-dim input (MNIST-like)
    m, n = 10, 50  # 10 classes, 50 principal components
    a = np.random.randn(m) * 0.5
    W = np.random.randn(m, n) * 0.3

    # Generate test points
    n_test = 100
    X_test = np.random.randn(n_test, n)

    radii = []
    for x in X_test:
        scores = a + W @ x
        pred = np.argmax(scores)
        dists = []
        for j in range(m):
            if j == pred:
                continue
            rd = W[pred] - W[j]
            norm_rd = np.linalg.norm(rd)
            if norm_rd > 1e-15:
                margin = (a[pred] - a[j]) + rd @ x
                dists.append(margin / norm_rd)
        if dists:
            r = min(dists)
            radii.append(max(r, 0))  # Only count points in the correct cell
        else:
            radii.append(float('inf'))

    radii = np.array(radii)
    print(f"\nCertified radius statistics (n={n_test}):")
    print(f"  Mean: {np.mean(radii):.4f}")
    print(f"  Median: {np.median(radii):.4f}")
    print(f"  Min: {np.min(radii):.4f}")
    print(f"  Max: {np.max(radii):.4f}")
    print(f"  Fraction with r > 0.1: {np.mean(radii > 0.1):.2%}")
    print(f"  Fraction with r > 0.5: {np.mean(radii > 0.5):.2%}")

    return radii

# ============================================================================
# Application 2: Comparison with Lipschitz-based bounds
# ============================================================================

def demo_lipschitz_comparison():
    """
    Compare exact Chebyshev radius with conservative Lipschitz-based bounds.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Exact Radius vs Lipschitz Bound Comparison")
    print("=" * 60)

    np.random.seed(123)
    m, n = 4, 3
    a = np.array([0.0, -0.5, -1.0, -0.3])
    W = np.array([
        [1.0, 0.5, 0.2],
        [0.3, 1.2, -0.1],
        [-0.5, 0.8, 0.9],
        [0.7, -0.3, 0.6]
    ])

    # Global Lipschitz constant: max over all pairs of ‖W_i - W_j‖
    global_lip = 0
    for i in range(m):
        for j in range(m):
            if i != j:
                global_lip = max(global_lip, np.linalg.norm(W[i] - W[j]))

    n_test = 50
    X_test = np.random.randn(n_test, n)

    exact_radii = []
    lipschitz_radii = []

    for x in X_test:
        scores = a + W @ x
        pred = np.argmax(scores)

        # Exact Chebyshev radius
        min_dist = float('inf')
        for j in range(m):
            if j == pred:
                continue
            rd = W[pred] - W[j]
            norm_rd = np.linalg.norm(rd)
            margin = (a[pred] - a[j]) + rd @ x
            if norm_rd > 1e-15:
                min_dist = min(min_dist, margin / norm_rd)

        exact_r = max(min_dist, 0)
        exact_radii.append(exact_r)

        # Conservative Lipschitz bound: min_margin / (2 * global_lip)
        min_margin = float('inf')
        for j in range(m):
            if j == pred:
                continue
            margin = scores[pred] - scores[j]
            min_margin = min(min_margin, margin)
        lip_r = max(min_margin / (2 * global_lip), 0)
        lipschitz_radii.append(lip_r)

    exact_radii = np.array(exact_radii)
    lipschitz_radii = np.array(lipschitz_radii)
    improvement = exact_radii / np.maximum(lipschitz_radii, 1e-15)

    print(f"\nExact radius - mean: {np.mean(exact_radii):.4f}")
    print(f"Lipschitz bound - mean: {np.mean(lipschitz_radii):.4f}")
    print(f"Average improvement factor: {np.mean(improvement[lipschitz_radii > 1e-10]):.2f}x")
    print(f"Max improvement factor: {np.max(improvement[lipschitz_radii > 1e-10]):.2f}x")

    # Visualization
    fig, ax = plt.subplots(figsize=(7, 7))
    ax.scatter(lipschitz_radii, exact_radii, c='steelblue', alpha=0.7, s=50)
    max_val = max(np.max(exact_radii), np.max(lipschitz_radii)) * 1.1
    ax.plot([0, max_val], [0, max_val], 'k--', linewidth=1, label='y = x (equality)')
    ax.set_xlabel('Conservative Lipschitz Bound', fontsize=13)
    ax.set_ylabel('Exact Chebyshev Radius', fontsize=13)
    ax.set_title('Exact vs Conservative Certified Radius', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_aspect('equal')
    plt.tight_layout()
    plt.savefig('/workspace/request-project/visualization_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()

    return exact_radii, lipschitz_radii

# ============================================================================
# Application 3: Active Facet Analysis
# ============================================================================

def demo_active_facets():
    """
    Identify which decision boundaries are 'active' (nearest) across the input space.
    This is key for algorithmic robust certification.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Active Facet Analysis")
    print("=" * 60)

    np.random.seed(42)
    m, n = 3, 2
    a = np.array([0.0, -0.8, -0.5])
    W = np.array([
        [1.0, 0.3],
        [0.2, 1.0],
        [-0.3, 0.6]
    ])

    # Grid analysis
    xx, yy = np.meshgrid(np.linspace(-2, 4, 100), np.linspace(-2, 4, 100))
    grid = np.c_[xx.ravel(), yy.ravel()]

    active_facets = np.full(len(grid), -1)
    radii = np.zeros(len(grid))

    for idx, x in enumerate(grid):
        scores = a + W @ x
        pred = np.argmax(scores)
        min_dist = float('inf')
        min_j = -1
        for j in range(m):
            if j == pred:
                continue
            rd = W[pred] - W[j]
            norm_rd = np.linalg.norm(rd)
            if norm_rd > 1e-15:
                margin = (a[pred] - a[j]) + rd @ x
                d = margin / norm_rd
                if d < min_dist:
                    min_dist = d
                    min_j = j
        active_facets[idx] = min_j
        radii[idx] = max(min_dist, 0)

    active_map = active_facets.reshape(xx.shape)
    radius_map = radii.reshape(xx.shape)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    ax1 = axes[0]
    im = ax1.contourf(xx, yy, radius_map, levels=20, cmap='viridis')
    plt.colorbar(im, ax=ax1, label='Chebyshev Radius')
    # Decision boundaries
    scores_grid = a[None, :] + grid @ W.T
    for j1 in range(m):
        for j2 in range(j1+1, m):
            margin = (scores_grid[:, j1] - scores_grid[:, j2]).reshape(xx.shape)
            ax1.contour(xx, yy, margin, levels=[0], colors='white', linewidths=2)
    ax1.set_title('Chebyshev Radius Heat Map', fontsize=14, fontweight='bold')
    ax1.set_xlabel('x₁', fontsize=12)
    ax1.set_ylabel('x₂', fontsize=12)

    ax2 = axes[1]
    colors_facet = ['#FF5722', '#4CAF50', '#9C27B0']
    for j in range(m):
        mask = (active_map == j)
        ax2.contourf(xx, yy, mask.astype(float), levels=[0.5, 1.5],
                     colors=[colors_facet[j]], alpha=0.3)
    for j1 in range(m):
        for j2 in range(j1+1, m):
            margin = (scores_grid[:, j1] - scores_grid[:, j2]).reshape(xx.shape)
            ax2.contour(xx, yy, margin, levels=[0], colors='black', linewidths=2)
    ax2.set_title('Active Facet Map (nearest boundary)', fontsize=14, fontweight='bold')
    ax2.set_xlabel('x₁', fontsize=12)
    ax2.set_ylabel('x₂', fontsize=12)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/visualization_active_facets.png', dpi=150, bbox_inches='tight')
    plt.close()

    print("Active facet visualization saved.")


if __name__ == "__main__":
    radii = demo_image_robustness()
    exact, lip = demo_lipschitz_comparison()
    demo_active_facets()
    print("\nAll applications complete!")


"""
Tropical Chebyshev Radius: Demonstrations and Numerical Examples

This script demonstrates the core theorem: for a tropical affine classifier,
the certified robustness radius equals the minimum Euclidean distance to the
pairwise decision boundaries.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Tuple, List

def score(a: np.ndarray, W: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Compute tropical affine scores: score_i(x) = a_i + W_i · x"""
    return a + W @ x

def margin_diff(a: np.ndarray, W: np.ndarray, i: int, j: int, x: np.ndarray) -> float:
    """Margin difference: score_i(x) - score_j(x)"""
    return float(score(a, W, x)[i] - score(a, W, x)[j])

def row_diff(W: np.ndarray, i: int, j: int) -> np.ndarray:
    """Row difference: W_i - W_j"""
    return W[i] - W[j]

def boundary_distance(a: np.ndarray, W: np.ndarray, i: int, j: int, x0: np.ndarray) -> float:
    """Euclidean distance from x0 to the decision boundary between classes i and j."""
    rd = row_diff(W, i, j)
    norm_rd = np.linalg.norm(rd)
    if norm_rd < 1e-15:
        return float('inf')
    return margin_diff(a, W, i, j, x0) / norm_rd

def chebyshev_radius(a: np.ndarray, W: np.ndarray, i: int, x0: np.ndarray) -> Tuple[float, int]:
    """
    Compute the Chebyshev radius (certified robustness radius) for class i at x0.
    Returns (radius, minimizing_competitor_index).
    """
    m = a.shape[0]
    min_dist = float('inf')
    min_j = -1
    for j in range(m):
        if j == i:
            continue
        d = boundary_distance(a, W, i, j, x0)
        if d < min_dist:
            min_dist = d
            min_j = j
    return min_dist, min_j

def verify_ball_inclusion(a: np.ndarray, W: np.ndarray, i: int, x0: np.ndarray,
                          r: float, n_samples: int = 10000) -> bool:
    """Verify by random sampling that the ball of radius r stays in the margin cell."""
    n = x0.shape[0]
    for _ in range(n_samples):
        # Random direction on unit sphere
        d = np.random.randn(n)
        d = d / np.linalg.norm(d)
        # Random radius in [0, r]
        t = np.random.uniform(0, r)
        x = x0 + t * d
        scores = score(a, W, x)
        if scores[i] < np.max(scores) - 1e-10:
            return False
    return True

def verify_sharpness(a: np.ndarray, W: np.ndarray, i: int, x0: np.ndarray,
                     r: float, j_star: int, epsilon: float = 0.01) -> bool:
    """Verify sharpness: moving distance r+epsilon in the critical direction leaves the cell."""
    rd = row_diff(W, i, j_star)
    v = rd / np.linalg.norm(rd)
    x = x0 - (r + epsilon) * v
    md = margin_diff(a, W, i, j_star, x)
    return md < 0

# ============================================================================
# EXAMPLE 1: 2D, 3-class classifier
# ============================================================================

print("=" * 70)
print("EXAMPLE 1: 2D Three-Class Tropical Affine Classifier")
print("=" * 70)

np.random.seed(42)

# 3 classes, 2D input
a = np.array([0.0, -1.0, -0.5])
W = np.array([
    [1.0, 0.5],
    [0.3, 1.2],
    [-0.5, 0.8]
])

x0 = np.array([1.0, 0.5])
scores_at_x0 = score(a, W, x0)
predicted_class = np.argmax(scores_at_x0)

print(f"\nBias vector a = {a}")
print(f"Weight matrix W =\n{W}")
print(f"Test point x0 = {x0}")
print(f"Scores at x0 = {scores_at_x0}")
print(f"Predicted class = {predicted_class}")

r, j_star = chebyshev_radius(a, W, predicted_class, x0)
print(f"\nChebyshev radius r = {r:.6f}")
print(f"Nearest boundary competitor j* = {j_star}")

# Verify
for j in range(3):
    if j == predicted_class:
        continue
    d = boundary_distance(a, W, predicted_class, j, x0)
    print(f"  Distance to boundary(class {predicted_class} vs {j}) = {d:.6f}")

# Verify ball inclusion by sampling
included = verify_ball_inclusion(a, W, predicted_class, x0, r)
print(f"\nBall inclusion verified (sampling): {included}")

# Verify sharpness
sharp = verify_sharpness(a, W, predicted_class, x0, r, j_star, epsilon=0.001)
print(f"Sharpness verified (epsilon=0.001): {sharp}")

# ============================================================================
# EXAMPLE 2: Higher dimensional
# ============================================================================

print("\n" + "=" * 70)
print("EXAMPLE 2: 5D Five-Class Tropical Affine Classifier")
print("=" * 70)

m, n = 5, 5
np.random.seed(123)
a2 = np.random.randn(m)
W2 = np.random.randn(m, n)
x0_2 = np.random.randn(n)

scores2 = score(a2, W2, x0_2)
pred2 = np.argmax(scores2)

r2, j_star2 = chebyshev_radius(a2, W2, pred2, x0_2)
print(f"Predicted class = {pred2}")
print(f"Chebyshev radius = {r2:.6f}")
print(f"Nearest competitor = {j_star2}")

included2 = verify_ball_inclusion(a2, W2, pred2, x0_2, r2)
sharp2 = verify_sharpness(a2, W2, pred2, x0_2, r2, j_star2)
print(f"Ball inclusion verified: {included2}")
print(f"Sharpness verified: {sharp2}")

# ============================================================================
# VISUALIZATION
# ============================================================================

print("\n" + "=" * 70)
print("Generating visualizations...")
print("=" * 70)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Plot 1: Decision regions and Chebyshev ball ---
ax = axes[0]
xx, yy = np.meshgrid(np.linspace(-2, 4, 300), np.linspace(-2, 4, 300))
grid = np.c_[xx.ravel(), yy.ravel()]
scores_grid = (a[None, :] + grid @ W.T)
classes_grid = np.argmax(scores_grid, axis=1).reshape(xx.shape)

colors = ['#2196F3', '#FF5722', '#4CAF50']
cmap = matplotlib.colors.ListedColormap(colors)
ax.contourf(xx, yy, classes_grid, levels=[-0.5, 0.5, 1.5, 2.5], colors=colors, alpha=0.25)

# Decision boundaries
for j1 in range(3):
    for j2 in range(j1+1, 3):
        margin_grid = scores_grid[:, j1].reshape(xx.shape) - scores_grid[:, j2].reshape(xx.shape)
        ax.contour(xx, yy, margin_grid, levels=[0], colors='black', linewidths=1.5)

# Chebyshev ball
circle = plt.Circle(x0, r, fill=False, color='red', linewidth=2.5, linestyle='-', label=f'Chebyshev ball (r={r:.3f})')
ax.add_patch(circle)
ax.plot(*x0, 'ko', markersize=8, zorder=5)
ax.annotate('x₀', x0 + np.array([0.05, 0.08]), fontsize=14, fontweight='bold')

# Critical direction
rd_star = row_diff(W, predicted_class, j_star)
v_star = rd_star / np.linalg.norm(rd_star)
boundary_point = x0 - r * v_star
ax.plot(*boundary_point, 'r^', markersize=10, zorder=5, label='Nearest boundary point')
ax.plot([x0[0], boundary_point[0]], [x0[1], boundary_point[1]], 'r--', linewidth=1.5)

ax.set_xlim(-1, 3.5)
ax.set_ylim(-1, 3)
ax.set_xlabel('x₁', fontsize=13)
ax.set_ylabel('x₂', fontsize=13)
ax.set_title('Decision Regions & Chebyshev Ball', fontsize=14, fontweight='bold')
ax.legend(loc='upper left', fontsize=10)
ax.set_aspect('equal')

# --- Plot 2: Margin vs distance in critical direction ---
ax2 = axes[1]
t_vals = np.linspace(0, r * 1.5, 200)
for j in range(3):
    if j == predicted_class:
        continue
    rd = row_diff(W, predicted_class, j)
    v = rd / np.linalg.norm(rd)
    margins = [margin_diff(a, W, predicted_class, j, x0 - t * v) for t in t_vals]
    ax2.plot(t_vals, margins, linewidth=2, label=f'Margin(class {predicted_class} vs {j})')

ax2.axhline(y=0, color='black', linewidth=0.8, linestyle='-')
ax2.axvline(x=r, color='red', linewidth=2, linestyle='--', label=f'r = {r:.3f}')
ax2.fill_between(t_vals, -1, 1.5, where=t_vals <= r, alpha=0.1, color='green')
ax2.set_xlabel('Distance from x₀ (critical direction)', fontsize=13)
ax2.set_ylabel('Margin value', fontsize=13)
ax2.set_title('Margin Decay Along Critical Direction', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_ylim(-0.5, max([margin_diff(a, W, predicted_class, j, x0) for j in range(3) if j != predicted_class]) * 1.2)

plt.tight_layout()
plt.savefig('/workspace/request-project/visualization_chebyshev_radius.png', dpi=150, bbox_inches='tight')
plt.close()

# --- Plot 3: Radius sensitivity analysis ---
fig2, ax3 = plt.subplots(figsize=(8, 5))
perturbation_scales = np.linspace(0, 2, 50)
radii_along_path = []
for s in perturbation_scales:
    x_test = x0 + s * np.array([1, 0])
    scores_test = score(a, W, x_test)
    pred_test = np.argmax(scores_test)
    if pred_test == predicted_class:
        r_test, _ = chebyshev_radius(a, W, predicted_class, x_test)
        radii_along_path.append((s, r_test))
    else:
        radii_along_path.append((s, 0))

ss, rr = zip(*radii_along_path)
ax3.plot(ss, rr, 'b-', linewidth=2)
ax3.fill_between(ss, 0, rr, alpha=0.15, color='blue')
ax3.set_xlabel('Displacement from x₀ along (1, 0)', fontsize=13)
ax3.set_ylabel('Chebyshev Radius', fontsize=13)
ax3.set_title('Certified Radius as a Function of Position', fontsize=14, fontweight='bold')
ax3.axhline(y=0, color='black', linewidth=0.8)
plt.tight_layout()
plt.savefig('/workspace/request-project/visualization_radius_sensitivity.png', dpi=150, bbox_inches='tight')
plt.close()

print("Visualizations saved.")
print("\nAll demonstrations complete!")
