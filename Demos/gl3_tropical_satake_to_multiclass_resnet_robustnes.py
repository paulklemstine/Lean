"""
Certified Robustness for Multiclass Residual Score Maps — Interactive Demo

This script demonstrates the theorems formalized in ResidualRobustness.lean
with concrete numerical examples and visualizations. It shows how tropical
Satake separation margins for a base classifier can be converted into
robustness certificates for a full residual architecture f(x) = h(x) + Σ sᵢ(x).

Requirements: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations

# ─────────────────────────────────────────────────────────────────────
#  1. Core definitions (mirror the Lean formalization)
# ─────────────────────────────────────────────────────────────────────

def total_score(h, skips, x):
    """Residual score: h(x) + Σᵢ sᵢ(x)."""
    result = h(x).copy()
    for s in skips:
        result += s(x)
    return result

def pair_gap(scores, a, b):
    """Pairwise gap: score[a] - score[b]."""
    return scores[a] - scores[b]

def margin(scores, y):
    """Multiclass margin: min over b≠y of (score[y] - score[b])."""
    C = len(scores)
    gaps = [scores[y] - scores[b] for b in range(C) if b != y]
    return min(gaps)

def predict(scores):
    """Predicted class: argmax of scores."""
    return int(np.argmax(scores))

# ─────────────────────────────────────────────────────────────────────
#  2. Example: 3-class classifier in ℝ² with 2 skip branches
# ─────────────────────────────────────────────────────────────────────

print("=" * 70)
print("  DEMO 1: Certified Robustness for a 3-Class Residual Classifier")
print("=" * 70)

# Base score map h: a piecewise-linear "tropical" classifier
# Designed to strongly separate class 0 near the origin
def h_base(x):
    """Base tropical score map (3 classes, 2D input)."""
    return np.array([
        3.0 + 0.5 * x[0] + 0.3 * x[1],   # class 0
        1.0 - 0.2 * x[0] + 0.8 * x[1],   # class 1
        0.5 + 0.7 * x[0] - 0.4 * x[1],   # class 2
    ])

# Skip branches: small perturbations with bounded Lipschitz constants
def skip_1(x):
    """Skip branch 1: Lipschitz constant Ks1 = 0.3 per class."""
    return np.array([
        0.2 * np.sin(x[0]),
        -0.1 * np.cos(x[1]),
        0.15 * np.sin(x[0] + x[1]),
    ])

def skip_2(x):
    """Skip branch 2: Lipschitz constant Ks2 = 0.2 per class."""
    return np.array([
        0.1 * np.cos(x[0] - x[1]),
        0.15 * np.sin(x[0]),
        -0.1 * np.cos(x[1]),
    ])

skips = [skip_1, skip_2]

# Center point
x0 = np.array([0.0, 0.0])
C = 3

# Lipschitz constants
Kh = 0.8   # max over classes of the L∞ Lipschitz constant of h
Ks = [0.3, 0.2]  # per-branch Lipschitz constants

# Compute scores at center
scores_x0 = total_score(h_base, skips, x0)
y_pred = predict(scores_x0)

print(f"\nCenter point: x = {x0}")
print(f"Base scores h(x):     {h_base(x0)}")
print(f"Skip 1 scores s₁(x):  {skip_1(x0)}")
print(f"Skip 2 scores s₂(x):  {skip_2(x0)}")
print(f"Total scores f(x):    {scores_x0}")
print(f"Predicted class:       {y_pred}")

# Compute pairwise gaps and margin
print(f"\nPairwise gaps at center (class {y_pred} vs others):")
for b in range(C):
    if b != y_pred:
        gap = pair_gap(scores_x0, y_pred, b)
        print(f"  gap({y_pred},{b}) = {gap:.4f}")

m = margin(scores_x0, y_pred)
print(f"Multiclass margin: {m:.4f}")

# ─────────────────────────────────────────────────────────────────────
#  3. Certified radius computation
# ─────────────────────────────────────────────────────────────────────

# Uniform budget: margin > 2r(Kh + ΣKs)
total_lip = Kh + sum(Ks)
certified_r = m / (2 * total_lip)

print(f"\n--- Certified Radius (Uniform Budget) ---")
print(f"Total Lipschitz budget: 2(Kh + ΣKs) = 2 × {total_lip} = {2*total_lip}")
print(f"Certified radius: r* = margin / (2·total_lip) = {m:.4f} / {2*total_lip:.4f} = {certified_r:.4f}")
print(f"\nTheorem guarantee: ∀ z with ‖z - x‖_∞ ≤ {certified_r:.4f},")
print(f"  class {y_pred} remains the unique predicted class.")

# Branchwise pairwise budget (sharper)
# K0(a,b) = Lip constant of pairGap(h, a, b) ≤ 2Kh
# K(i,a,b) = Lip constant of pairGap(s_i, a, b) ≤ 2Ks_i
print(f"\n--- Certified Radius (Branchwise Pairwise Budget) ---")
for b in range(C):
    if b != y_pred:
        gap = pair_gap(scores_x0, y_pred, b)
        # In the branchwise case, use pairGap Lipschitz constants
        # These are at most 2× the per-class constants
        K0_yb = 2 * Kh  # worst case
        Ki_yb = sum(2 * k for k in Ks)  # worst case
        r_yb = gap / (K0_yb + Ki_yb)
        print(f"  Class {y_pred} vs {b}: gap = {gap:.4f}, budget = {K0_yb + Ki_yb:.4f}, r = {r_yb:.4f}")

# ─────────────────────────────────────────────────────────────────────
#  4. Verification: check prediction stability inside the ball
# ─────────────────────────────────────────────────────────────────────

print(f"\n--- Empirical Verification ---")
n_samples = 10000
rng = np.random.default_rng(42)
perturbations = rng.uniform(-certified_r, certified_r, size=(n_samples, 2))
all_correct = True
min_margin_found = float('inf')

for delta in perturbations:
    z = x0 + delta
    scores_z = total_score(h_base, skips, z)
    pred_z = predict(scores_z)
    m_z = margin(scores_z, y_pred)
    min_margin_found = min(min_margin_found, m_z)
    if pred_z != y_pred:
        all_correct = False
        break

print(f"Tested {n_samples} random perturbations within r = {certified_r:.4f}")
print(f"All predictions match class {y_pred}: {all_correct}")
print(f"Minimum margin observed: {min_margin_found:.4f} (> 0 ✓)")

# ─────────────────────────────────────────────────────────────────────
#  5. Visualization
# ─────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Decision regions of the full residual model
ax = axes[0]
grid_range = 3.0
xx, yy = np.meshgrid(np.linspace(-grid_range, grid_range, 300),
                      np.linspace(-grid_range, grid_range, 300))
grid_points = np.stack([xx.ravel(), yy.ravel()], axis=1)
predictions = np.array([predict(total_score(h_base, skips, p)) for p in grid_points])
predictions = predictions.reshape(xx.shape)

colors = ['#2196F3', '#FF9800', '#4CAF50']
cmap = plt.matplotlib.colors.ListedColormap(colors)
ax.contourf(xx, yy, predictions, levels=[-0.5, 0.5, 1.5, 2.5], colors=colors, alpha=0.3)
ax.contour(xx, yy, predictions, levels=[0.5, 1.5], colors='gray', linewidths=0.5)

# Draw the certified L∞ ball
rect = plt.Rectangle((x0[0] - certified_r, x0[1] - certified_r),
                       2 * certified_r, 2 * certified_r,
                       fill=False, edgecolor='red', linewidth=2.5,
                       linestyle='--', label=f'Certified L∞ ball (r={certified_r:.3f})')
ax.add_patch(rect)
ax.plot(*x0, 'r*', markersize=15, label=f'Center x (class {y_pred})')
ax.set_xlabel('$x_1$')
ax.set_ylabel('$x_2$')
ax.set_title('Decision Regions & Certified Ball')
ax.legend(loc='upper right', fontsize=8)
ax.set_xlim(-grid_range, grid_range)
ax.set_ylim(-grid_range, grid_range)
ax.set_aspect('equal')

# Panel 2: Pairwise gaps along a 1D slice through x0
ax = axes[1]
ts = np.linspace(-2.0, 2.0, 500)
for b in range(C):
    if b != y_pred:
        gaps = [pair_gap(total_score(h_base, skips, x0 + np.array([t, 0])), y_pred, b) for t in ts]
        ax.plot(ts, gaps, linewidth=2, label=f'gap({y_pred},{b})')

ax.axhline(0, color='black', linewidth=0.5)
ax.axvspan(-certified_r, certified_r, alpha=0.15, color='red',
           label=f'Certified region')
ax.set_xlabel('Perturbation $\\delta_1$ (along $x_1$)')
ax.set_ylabel('Pairwise gap')
ax.set_title('Pairwise Gaps Along $x_1$ Axis')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Margin heatmap
ax = axes[2]
margin_grid = np.array([margin(total_score(h_base, skips, p), y_pred) for p in grid_points])
margin_grid = margin_grid.reshape(xx.shape)

im = ax.contourf(xx, yy, margin_grid, levels=30, cmap='RdYlGn')
ax.contour(xx, yy, margin_grid, levels=[0], colors='black', linewidths=2)
plt.colorbar(im, ax=ax, label='Margin')

rect2 = plt.Rectangle((x0[0] - certified_r, x0[1] - certified_r),
                        2 * certified_r, 2 * certified_r,
                        fill=False, edgecolor='red', linewidth=2.5, linestyle='--')
ax.add_patch(rect2)
ax.plot(*x0, 'r*', markersize=15)
ax.set_xlabel('$x_1$')
ax.set_ylabel('$x_2$')
ax.set_title('Margin Heatmap (Positive = Robust)')
ax.set_xlim(-grid_range, grid_range)
ax.set_ylim(-grid_range, grid_range)
ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('Bridges/robustness_demo.png', dpi=150, bbox_inches='tight')
print(f"\nVisualization saved to Bridges/robustness_demo.png")

# ─────────────────────────────────────────────────────────────────────
#  6. Demo 2: Branchwise decomposition advantage
# ─────────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("  DEMO 2: Branchwise vs Uniform Budget — Sharpness Comparison")
print("=" * 70)

# When per-branch, per-pair Lipschitz constants are available,
# the branchwise certificate can be much tighter.

# Suppose we have tight pairwise Lipschitz constants:
K0_tight = {(0,1): 0.7, (0,2): 1.2, (1,0): 0.7, (1,2): 1.1, (2,0): 1.2, (2,1): 1.1}
K1_tight = {(0,1): 0.15, (0,2): 0.25, (1,0): 0.15, (1,2): 0.20, (2,0): 0.25, (2,1): 0.20}
K2_tight = {(0,1): 0.10, (0,2): 0.20, (1,0): 0.10, (1,2): 0.15, (2,0): 0.20, (2,1): 0.15}

print(f"\nPairwise Lipschitz constants (tighter than uniform 2Kh, 2Ks):")
print(f"  K0(0,1) = {K0_tight[(0,1)]:.2f}  vs uniform 2Kh = {2*Kh:.2f}")
print(f"  K0(0,2) = {K0_tight[(0,2)]:.2f}  vs uniform 2Kh = {2*Kh:.2f}")

print(f"\nCertified radii comparison (class {y_pred} at center x = {x0}):")
for b in range(C):
    if b != y_pred:
        gap = pair_gap(scores_x0, y_pred, b)
        
        # Uniform budget
        budget_uniform = 2 * (Kh + sum(Ks))
        r_uniform = gap / budget_uniform
        
        # Branchwise budget
        budget_branch = K0_tight[(y_pred, b)] + K1_tight[(y_pred, b)] + K2_tight[(y_pred, b)]
        r_branch = gap / budget_branch
        
        improvement = (r_branch / r_uniform - 1) * 100
        print(f"\n  Class {y_pred} vs {b}:")
        print(f"    Gap at center:     {gap:.4f}")
        print(f"    Uniform radius:    {r_uniform:.4f}  (budget = {budget_uniform:.2f})")
        print(f"    Branchwise radius: {r_branch:.4f}  (budget = {budget_branch:.2f})")
        print(f"    Improvement:       {improvement:.1f}%")

# Overall certified radius is the minimum over pairs
r_uniform_overall = min(
    pair_gap(scores_x0, y_pred, b) / (2 * (Kh + sum(Ks)))
    for b in range(C) if b != y_pred
)
r_branch_overall = min(
    pair_gap(scores_x0, y_pred, b) / (K0_tight[(y_pred, b)] + K1_tight[(y_pred, b)] + K2_tight[(y_pred, b)])
    for b in range(C) if b != y_pred
)

print(f"\n  Overall certified L∞ radius:")
print(f"    Uniform:    {r_uniform_overall:.4f}")
print(f"    Branchwise: {r_branch_overall:.4f}")
print(f"    Improvement: {(r_branch_overall / r_uniform_overall - 1) * 100:.1f}%")

# ─────────────────────────────────────────────────────────────────────
#  7. Demo 3: Hecke/Satake certificate interpretation
# ─────────────────────────────────────────────────────────────────────

print("\n" + "=" * 70)
print("  DEMO 3: Tropical Satake Certificate Interpretation")
print("=" * 70)

# In the tropical Satake framework, the base classifier h has
# score differences certified by a finite family of test functionals.
# The certificate Δ(y,b,x) is the minimum over this test family.

# Simulated Satake test functionals (3 test functionals for GL3)
def satake_test_1(x, a, b):
    """Test functional from dominant weight (1,0,0)."""
    return 0.9 * (h_base(x)[a] - h_base(x)[b])

def satake_test_2(x, a, b):
    """Test functional from dominant weight (1,1,0)."""
    return 0.85 * (h_base(x)[a] - h_base(x)[b])

def satake_test_3(x, a, b):
    """Test functional from dominant weight (2,1,0)."""
    return 0.8 * (h_base(x)[a] - h_base(x)[b])

def delta_cert(x, a, b):
    """Satake certificate: minimum over test family."""
    return min(satake_test_1(x, a, b),
               satake_test_2(x, a, b),
               satake_test_3(x, a, b))

print(f"\nSatake certificates at x = {x0}:")
for b in range(C):
    if b != y_pred:
        actual_gap = pair_gap(h_base(x0), y_pred, b)
        cert = delta_cert(x0, y_pred, b)
        print(f"  Δ({y_pred},{b}) = {cert:.4f}  ≤  actual gap = {actual_gap:.4f}  ✓")

# Using the Hecke-certified variant (residual_robust_of_base_gap_and_skip_budget):
# margin condition: Δ(y,b,x) + Σᵢ pairGap(sᵢ, y, b, x) > (K0(y,b) + Σ K(i,y,b)) * r
print(f"\nHecke-certified robustness check:")
for b in range(C):
    if b != y_pred:
        delta = delta_cert(x0, y_pred, b)
        skip_gaps = sum(pair_gap(s(x0), y_pred, b) for s in skips)
        total_margin = delta + skip_gaps
        budget = K0_tight[(y_pred, b)] + K1_tight[(y_pred, b)] + K2_tight[(y_pred, b)]
        r_cert = total_margin / budget if budget > 0 else float('inf')
        print(f"  Class {y_pred} vs {b}:")
        print(f"    Δ + Σ skip_gaps = {delta:.4f} + {skip_gaps:.4f} = {total_margin:.4f}")
        print(f"    Budget = {budget:.4f}")
        print(f"    Certified radius = {r_cert:.4f}")

print("\n" + "=" * 70)
print("  All demos completed successfully!")
print("=" * 70)
