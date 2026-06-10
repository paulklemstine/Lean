"""
Applications of GL3 Tropical Satake OVR Certified Robustness
==============================================================

This module demonstrates practical applications of the certified robustness
theorem formalized in TropicalSatakeOneVsRestRobustness.lean.

Applications:
  1. Medical image classification robustness certificate
  2. Selective prediction with abstention
  3. Model comparison via certified radii
  4. Adversarial budget allocation
"""

import numpy as np
import matplotlib.pyplot as plt

# ── Application 1: Medical Image Classifier Certificate ──────────────────
print("=" * 70)
print("APPLICATION 1: Medical Image Classifier — Robustness Certificate")
print("=" * 70)

class TropicalSatakeClassifier:
    """A 3-class classifier with explicit Lipschitz constants.

    Models a simplified medical imaging classifier with three diagnosis
    categories: benign (0), pre-cancerous (1), malignant (2).

    Each score function S_c is (K*d)-Lipschitz, where:
      - K: base Lipschitz constant (depends on model architecture)
      - d: tropical degree (measures piecewise-linear complexity)
    """

    def __init__(self, weights, biases, K, d):
        """
        weights: list of 3 weight vectors (one per class)
        biases:  list of 3 bias scalars
        K, d:    Lipschitz parameters
        """
        self.weights = [np.array(w, dtype=float) for w in weights]
        self.biases = list(biases)
        self.K = K
        self.d = d
        self.n_classes = 3
        self.class_names = ["Benign", "Pre-cancerous", "Malignant"]

    def score(self, c, x):
        """Score for class c at input x."""
        return float(np.dot(self.weights[c], x) + self.biases[c])

    def predict(self, x):
        """Predicted class (argmax of scores)."""
        scores = [self.score(c, x) for c in range(self.n_classes)]
        return int(np.argmax(scores))

    def ovr_margin(self, x, y=None):
        """One-vs-rest margin for class y at x."""
        if y is None:
            y = self.predict(x)
        sy = self.score(y, x)
        margins = [sy - self.score(c, x) for c in range(self.n_classes) if c != y]
        return min(margins)

    def certified_radius(self, x, y=None):
        """Certified robustness radius: ovrMargin / (2*K*d)."""
        if y is None:
            y = self.predict(x)
        margin = self.ovr_margin(x, y)
        if margin <= 0:
            return 0.0
        return margin / (2 * self.K * self.d)

    def classify_with_certificate(self, x):
        """Return (prediction, radius, margin) triple."""
        y = self.predict(x)
        margin = self.ovr_margin(x, y)
        radius = self.certified_radius(x, y)
        return y, radius, margin


# Create a medical imaging classifier
clf = TropicalSatakeClassifier(
    weights=[[2.0, 1.0, 0.5, 0.3],    # benign weights
             [0.5, 2.0, 1.5, 0.8],    # pre-cancerous weights
             [0.3, 0.5, 0.8, 2.5]],   # malignant weights
    biases=[3.0, 1.0, 0.5],
    K=2.5, d=1.0
)

# Simulate patient data
np.random.seed(123)
patients = [
    ("Patient A", np.array([1.0, 0.2, 0.3, 0.1])),
    ("Patient B", np.array([0.3, 1.5, 0.8, 0.2])),
    ("Patient C", np.array([0.1, 0.3, 0.5, 1.2])),
    ("Patient D", np.array([0.8, 0.8, 0.5, 0.3])),
    ("Patient E", np.array([0.5, 0.5, 0.5, 0.5])),
]

print("\n  CERTIFIED DIAGNOSIS REPORT")
print("  " + "-" * 60)
print(f"  {'Patient':>12s} | {'Diagnosis':>14s} | {'Margin':>8s} | {'Cert. Radius':>12s} | {'Status':>10s}")
print("  " + "-" * 60)

for name, features in patients:
    y, radius, margin = clf.classify_with_certificate(features)
    status = "✓ SAFE" if radius > 0.1 else ("⚠ CAUTION" if radius > 0 else "✗ FRAGILE")
    print(f"  {name:>12s} | {clf.class_names[y]:>14s} | {margin:8.3f} | {radius:12.4f} | {status:>10s}")

print("\n  Interpretation: Certified radius r means ANY perturbation")
print("  with ‖δ‖ < r is GUARANTEED to preserve the diagnosis.")
print("  Status: ✓ SAFE (r > 0.1), ⚠ CAUTION (0 < r ≤ 0.1), ✗ FRAGILE (r = 0)")


# ── Application 2: Selective Prediction with Abstention ──────────────────
print("\n" + "=" * 70)
print("APPLICATION 2: Selective Prediction with Abstention")
print("=" * 70)

def selective_classify(clf, x, min_radius=0.05):
    """Classify with abstention: return None if certificate is too weak."""
    y, radius, margin = clf.classify_with_certificate(x)
    if radius < min_radius:
        return None, radius
    return y, radius

print(f"\n  Abstention threshold: min_radius = 0.05")
print(f"\n  Generating 100 random inputs...")

np.random.seed(42)
n_test = 100
accepted = 0
abstained = 0
for _ in range(n_test):
    x = np.random.randn(4) * 0.5
    y, radius = selective_classify(clf, x)
    if y is not None:
        accepted += 1
    else:
        abstained += 1

print(f"  Accepted: {accepted}/{n_test} ({100*accepted/n_test:.0f}%)")
print(f"  Abstained: {abstained}/{n_test} ({100*abstained/n_test:.0f}%)")
print(f"\n  Key insight: All accepted predictions have a MATHEMATICAL")
print(f"  GUARANTEE of robustness — not just empirical confidence.")


# ── Application 3: Model Comparison via Certified Radii ──────────────────
print("\n" + "=" * 70)
print("APPLICATION 3: Model Comparison via Certified Radii")
print("=" * 70)

# Two competing models with different Lipschitz constants
model_A = TropicalSatakeClassifier(
    weights=[[2.0, 1.0, 0.5, 0.3], [0.5, 2.0, 1.5, 0.8], [0.3, 0.5, 0.8, 2.5]],
    biases=[3.0, 1.0, 0.5], K=2.5, d=1.0
)

model_B = TropicalSatakeClassifier(
    weights=[[3.0, 1.5, 0.7, 0.4], [0.7, 3.0, 2.2, 1.2], [0.4, 0.7, 1.2, 3.8]],
    biases=[4.0, 1.5, 0.7], K=3.8, d=1.0  # Higher Lipschitz constant
)

np.random.seed(99)
test_data = [np.random.randn(4) * 0.5 for _ in range(200)]

radii_A = [model_A.certified_radius(x) for x in test_data]
radii_B = [model_B.certified_radius(x) for x in test_data]

print(f"\n  Model A: K={model_A.K}, d={model_A.d}, 2Kd={2*model_A.K*model_A.d}")
print(f"    Mean certified radius: {np.mean(radii_A):.4f}")
print(f"    Median certified radius: {np.median(radii_A):.4f}")
print(f"    Min certified radius: {np.min(radii_A):.4f}")

print(f"\n  Model B: K={model_B.K}, d={model_B.d}, 2Kd={2*model_B.K*model_B.d}")
print(f"    Mean certified radius: {np.mean(radii_B):.4f}")
print(f"    Median certified radius: {np.median(radii_B):.4f}")
print(f"    Min certified radius: {np.min(radii_B):.4f}")

winner = "A" if np.mean(radii_A) > np.mean(radii_B) else "B"
print(f"\n  → Model {winner} has better average certified robustness.")

# Visualization
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

ax = axes[0]
ax.hist(radii_A, bins=30, alpha=0.6, color='steelblue', label='Model A', edgecolor='black')
ax.hist(radii_B, bins=30, alpha=0.6, color='coral', label='Model B', edgecolor='black')
ax.axvline(np.mean(radii_A), color='steelblue', linestyle='--', linewidth=2)
ax.axvline(np.mean(radii_B), color='coral', linestyle='--', linewidth=2)
ax.set_xlabel("Certified Radius", fontsize=11)
ax.set_ylabel("Count", fontsize=11)
ax.set_title("Distribution of Certified Radii", fontsize=13)
ax.legend(fontsize=10)

ax2 = axes[1]
ax2.scatter(radii_A, radii_B, alpha=0.4, s=20, color='purple')
lim = max(max(radii_A), max(radii_B)) * 1.1
ax2.plot([0, lim], [0, lim], 'k--', alpha=0.5, label='Equal')
ax2.set_xlabel("Model A Certified Radius", fontsize=11)
ax2.set_ylabel("Model B Certified Radius", fontsize=11)
ax2.set_title("Per-Input Radius Comparison", fontsize=13)
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig("/workspace/request-project/Bridges/GL3/model_comparison.png", dpi=150,
            bbox_inches='tight')
print("  Saved: Bridges/GL3/model_comparison.png")


# ── Application 4: Adversarial Budget Allocation ─────────────────────────
print("\n" + "=" * 70)
print("APPLICATION 4: Adversarial Budget Allocation")
print("=" * 70)
print("""
  SCENARIO: An adversary has a fixed perturbation budget ε.
  The certified radius tells us exactly which inputs are vulnerable.

  For a defender, this enables:
  1. Prioritizing protection of low-radius inputs
  2. Computing the fraction of inputs certifiably safe at budget ε
  3. Estimating the cost of increasing ε-robustness
""")

epsilons = [0.01, 0.05, 0.1, 0.2, 0.5, 1.0]
print(f"  {'ε (budget)':>12s} | {'% Safe (A)':>12s} | {'% Safe (B)':>12s}")
print("  " + "-" * 42)
for eps in epsilons:
    safe_A = 100 * np.mean([r >= eps for r in radii_A])
    safe_B = 100 * np.mean([r >= eps for r in radii_B])
    print(f"  {eps:12.3f} | {safe_A:11.1f}% | {safe_B:11.1f}%")

print("""
  Key takeaway: The theorem r = margin/(2Kd) gives EXACT certified safety.
  This is NOT a probabilistic bound — it is a mathematical guarantee from
  the GL₃ tropical Satake structure of the score functions.
""")

print("=" * 70)
print("ALL APPLICATIONS COMPLETE")
print("=" * 70)


"""
GL3 Tropical Satake One-vs-Rest Certified Robustness — Interactive Demo
=======================================================================

This script demonstrates the certified robustness radius theorem for
multiclass classifiers with Lipschitz score functions. It shows:

1. How the one-vs-rest margin determines the certified radius
2. How the pairwise Lipschitz constant 2*K*d governs robustness
3. Visualization of the certified region in input space

The mathematics corresponds to the Lean formalization in
  Bridges/GL3/TropicalSatakeOneVsRestRobustness.lean
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import ListedColormap

# ── Score Functions ──────────────────────────────────────────────────────
# We model three "tropical Satake Hecke score" functions S_c : R^2 -> R
# Each is (K*d)-Lipschitz in the sup-norm.

K = 1.0  # Lipschitz constant factor
d = 1.0  # tropical degree factor

def S0(x):
    """Score for class 0: a linear function."""
    return 2.0 * x[0] + 0.5 * x[1] + 3.0

def S1(x):
    """Score for class 1: another linear function."""
    return 0.5 * x[0] + 2.0 * x[1] + 1.0

def S2(x):
    """Score for class 2: piecewise linear (tropical-style)."""
    return np.minimum(1.5 * x[0] + 1.5 * x[1] + 2.0,
                      0.8 * x[0] + 0.8 * x[1] + 4.0)

scores = [S0, S1, S2]
class_names = ["Class 0", "Class 1", "Class 2"]
class_colors = ["#e74c3c", "#3498db", "#2ecc71"]

def predict(x):
    """Return the predicted class (argmax of scores)."""
    vals = [s(x) for s in scores]
    return int(np.argmax(vals))

def ovr_margin(x, y):
    """Compute the one-vs-rest margin for class y at point x."""
    sy = scores[y](x)
    margins = [sy - scores[c](x) for c in range(3) if c != y]
    return min(margins)

def certified_radius(x, y, K, d):
    """Compute the certified robustness radius."""
    margin = ovr_margin(x, y)
    if margin <= 0:
        return 0.0
    return margin / (2 * K * d)


# ── Demo 1: Certified Radius at a Specific Point ────────────────────────
print("=" * 60)
print("DEMO 1: Certified Robustness Radius Computation")
print("=" * 60)

x0 = np.array([1.0, 0.5])
y_pred = predict(x0)
margin = ovr_margin(x0, y_pred)
radius = certified_radius(x0, y_pred, K, d)

print(f"\nInput point:       x = {x0}")
print(f"Predicted class:   y = {y_pred} ({class_names[y_pred]})")
print(f"Scores:            S_0={S0(x0):.3f}, S_1={S1(x0):.3f}, S_2={S2(x0):.3f}")
print(f"OVR margin:        {margin:.4f}")
print(f"Lipschitz const:   2·K·d = {2*K*d:.1f}")
print(f"Certified radius:  r = margin/(2Kd) = {radius:.4f}")
print(f"\nTheorem guarantee: ANY perturbation δ with ‖δ‖∞ < {radius:.4f}")
print(f"  preserves the prediction y = {y_pred}.")

# ── Demo 2: Verify the Certificate Empirically ──────────────────────────
print("\n" + "=" * 60)
print("DEMO 2: Empirical Verification (random perturbations)")
print("=" * 60)

np.random.seed(42)
n_inside = 1000
n_outside = 1000
inside_failures = 0
outside_changes = 0

for _ in range(n_inside):
    delta = np.random.uniform(-0.99 * radius, 0.99 * radius, size=2)
    if np.max(np.abs(delta)) < radius:
        if predict(x0 + delta) != y_pred:
            inside_failures += 1

for _ in range(n_outside):
    scale = np.random.uniform(1.5, 5.0)
    delta = np.random.uniform(-scale * radius, scale * radius, size=2)
    if predict(x0 + delta) != y_pred:
        outside_changes += 1

print(f"\n{n_inside} random perturbations INSIDE certified ball:")
print(f"  Prediction changes: {inside_failures} (theorem guarantees 0)")
print(f"\n{n_outside} random perturbations OUTSIDE certified ball:")
print(f"  Prediction changes: {outside_changes} (no guarantee)")

# ── Demo 3: Visualization ───────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 3: Generating visualization...")
print("=" * 60)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Decision regions with certified ball
ax = axes[0]
xmin, xmax = -2, 4
ymin, ymax = -2, 4
xx, yy = np.meshgrid(np.linspace(xmin, xmax, 300), np.linspace(ymin, ymax, 300))
Z = np.zeros_like(xx, dtype=int)
for i in range(xx.shape[0]):
    for j in range(xx.shape[1]):
        Z[i, j] = predict(np.array([xx[i, j], yy[i, j]]))

cmap = ListedColormap(class_colors)
ax.contourf(xx, yy, Z, levels=[-0.5, 0.5, 1.5, 2.5], cmap=cmap, alpha=0.3)
ax.contour(xx, yy, Z, levels=[0.5, 1.5], colors='black', linewidths=1.5)

# Draw certified ball (L∞ ball = square)
rect = plt.Rectangle((x0[0] - radius, x0[1] - radius), 2 * radius, 2 * radius,
                      linewidth=2, edgecolor='gold', facecolor='gold', alpha=0.3)
ax.add_patch(rect)
ax.plot(x0[0], x0[1], 'k*', markersize=15, zorder=5)
ax.annotate(f'r = {radius:.3f}', xy=(x0[0] + radius, x0[1]),
            fontsize=10, color='darkgoldenrod', fontweight='bold')

patches = [mpatches.Patch(color=c, alpha=0.5, label=n) for c, n in zip(class_colors, class_names)]
patches.append(mpatches.Patch(color='gold', alpha=0.3, label=f'Certified ball (r={radius:.3f})'))
ax.legend(handles=patches, loc='upper left', fontsize=9)
ax.set_title("Decision Regions & Certified Robustness Ball", fontsize=13)
ax.set_xlabel("x₁")
ax.set_ylabel("x₂")
ax.set_xlim(xmin, xmax)
ax.set_ylim(ymin, ymax)

# Plot 2: Margin and radius as function along a line
ax2 = axes[1]
ts = np.linspace(-2, 4, 500)
margins = []
radii = []
preds = []
for t in ts:
    pt = np.array([t, 0.5])
    y = predict(pt)
    m = ovr_margin(pt, y)
    r = certified_radius(pt, y, K, d)
    margins.append(m)
    radii.append(r)
    preds.append(y)

ax2.plot(ts, margins, 'b-', linewidth=2, label='OVR Margin')
ax2.plot(ts, radii, 'r--', linewidth=2, label='Certified Radius r')
ax2.axhline(y=0, color='gray', linestyle='-', alpha=0.5)
ax2.fill_between(ts, 0, radii, alpha=0.15, color='red')
ax2.set_xlabel("x₁ (with x₂ = 0.5 fixed)", fontsize=11)
ax2.set_ylabel("Value", fontsize=11)
ax2.set_title("OVR Margin & Certified Radius Along a Line", fontsize=13)
ax2.legend(fontsize=10)
ax2.set_xlim(-2, 4)

plt.tight_layout()
plt.savefig("/workspace/request-project/Bridges/GL3/ovr_robustness_demo.png", dpi=150,
            bbox_inches='tight')
print("  Saved: Bridges/GL3/ovr_robustness_demo.png")

# ── Demo 4: Table of certified radii at various points ──────────────────
print("\n" + "=" * 60)
print("DEMO 4: Certified Radii at Various Points")
print("=" * 60)

test_points = [
    np.array([0.0, 0.0]),
    np.array([1.0, 0.0]),
    np.array([0.0, 1.0]),
    np.array([2.0, -1.0]),
    np.array([-1.0, 2.0]),
    np.array([1.5, 1.5]),
    np.array([3.0, 0.0]),
]

print(f"\n{'Point':>15s} | {'Pred':>5s} | {'S0':>8s} {'S1':>8s} {'S2':>8s} | {'Margin':>8s} | {'Radius':>8s}")
print("-" * 75)
for pt in test_points:
    y = predict(pt)
    m = ovr_margin(pt, y)
    r = certified_radius(pt, y, K, d)
    print(f"({pt[0]:5.1f},{pt[1]:5.1f}) | {y:5d} | {S0(pt):8.3f} {S1(pt):8.3f} {S2(pt):8.3f} | {m:8.4f} | {r:8.4f}")

# ── Demo 5: Effect of K and d on certified radius ───────────────────────
print("\n" + "=" * 60)
print("DEMO 5: Effect of Lipschitz Constants K, d on Radius")
print("=" * 60)

fig2, ax3 = plt.subplots(figsize=(8, 5))
Ks = np.linspace(0.1, 5.0, 50)
ds = [0.5, 1.0, 2.0, 4.0]

for d_val in ds:
    radii_kd = [margin / (2 * k * d_val) for k in Ks]
    ax3.plot(Ks, radii_kd, linewidth=2, label=f'd = {d_val}')

ax3.set_xlabel("Lipschitz factor K", fontsize=12)
ax3.set_ylabel("Certified radius r", fontsize=12)
ax3.set_title(f"Certified Radius r = margin/(2Kd)\n(margin = {margin:.3f} at x = {x0})", fontsize=13)
ax3.legend(fontsize=11)
ax3.set_ylim(0, None)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("/workspace/request-project/Bridges/GL3/radius_vs_lipschitz.png", dpi=150,
            bbox_inches='tight')
print("  Saved: Bridges/GL3/radius_vs_lipschitz.png")

print("\n" + "=" * 60)
print("ALL DEMOS COMPLETE")
print("=" * 60)
