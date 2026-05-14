#!/usr/bin/env python3
"""
Applications of Tropical Adversarial Regularization

Real-world applications demonstrating the tropical robustness framework:
1. Certified defense for image classifiers (MNIST-like)
2. Robustness-accuracy tradeoff analysis
3. Tropical regularization vs. standard adversarial training
4. Multi-class certified radius computation
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import (
    compute_margin, certified_radius_from_lipschitz,
    tropical_erosion, tropical_regularized_risk, certify_dataset,
    hinge_loss, logistic_loss, linf_cost
)


def application_1_certified_defense():
    """
    Application 1: Certified defense for a simple neural network classifier.

    Demonstrates how tropical regularization provides provable robustness
    certificates for a multi-class classifier.
    """
    print("=" * 70)
    print("APPLICATION 1: Certified Defense via Tropical Regularization")
    print("=" * 70)

    np.random.seed(42)
    d, c = 10, 3  # 10-dimensional inputs, 3 classes

    # Simulate a trained classifier (random weights for demonstration)
    W = np.random.randn(c, d) * 0.5
    b = np.random.randn(c) * 0.1

    def score_fn(x):
        return W @ x + b

    # Compute Lipschitz constant for the margin
    # For linear classifier with L-inf cost:
    # margin(x', y) - margin(x, y) depends on (W[y] - W[j]) · (x' - x)
    # Lipschitz constant is max over j≠y of ||W[y] - W[j]||_1
    L = 0
    for y in range(c):
        for j in range(c):
            if j != y:
                L = max(L, np.sum(np.abs(W[y] - W[j])))

    print(f"  Dimensions: d={d}, classes={c}")
    print(f"  Margin Lipschitz constant: L = {L:.3f}")

    # Generate test dataset
    n_test = 50
    dataset = []
    for _ in range(n_test):
        x = np.random.randn(d)
        scores = score_fn(x)
        y = int(np.argmax(scores))
        dataset.append((x, y))

    # Certify all points
    certificates = certify_dataset(score_fn, dataset, L, hinge_loss, epsilon=0.1)

    # Statistics
    margins = [c.margin for c in certificates]
    radii = [c.certified_radius for c in certificates]
    robust_count = sum(1 for r in radii if r > 0.1)

    print(f"\n  Dataset size: {n_test}")
    print(f"  Mean margin: {np.mean(margins):.4f}")
    print(f"  Mean certified radius: {np.mean(radii):.4f}")
    print(f"  Min certified radius: {np.min(radii):.4f}")
    print(f"  Points certified robust at ε=0.1: {robust_count}/{n_test} "
          f"({100*robust_count/n_test:.1f}%)")

    # Visualize certified radius distribution
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    axes[0].hist(radii, bins=20, edgecolor='black', alpha=0.7, color='steelblue')
    axes[0].axvline(0.1, color='red', linestyle='--', linewidth=2, label='ε = 0.1')
    axes[0].set_xlabel('Certified Radius (margin / L)')
    axes[0].set_ylabel('Count')
    axes[0].set_title('Distribution of Tropical Certified Radii')
    axes[0].legend()

    axes[1].scatter(margins, radii, alpha=0.6, c='steelblue', edgecolors='black')
    axes[1].plot([0, max(margins)], [0, max(margins)/L], 'r--', label='r = m/L')
    axes[1].set_xlabel('Margin')
    axes[1].set_ylabel('Certified Radius')
    axes[1].set_title('Margin vs. Certified Radius')
    axes[1].legend()

    plt.tight_layout()
    plt.savefig('application_certified_defense.png', dpi=150, bbox_inches='tight')
    print("  Saved: application_certified_defense.png")
    plt.close()


def application_2_robustness_accuracy_tradeoff():
    """
    Application 2: Robustness-accuracy tradeoff via tropical regularization.

    Shows how increasing the perturbation budget ε affects the tropical
    regularized risk, revealing the fundamental tradeoff.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Robustness-Accuracy Tradeoff")
    print("=" * 70)

    np.random.seed(123)
    d, c = 5, 2
    W = np.array([[1.0, 0.5, -0.3, 0.8, -0.2],
                   [-0.5, 1.0, 0.4, -0.6, 0.3]])
    b = np.array([0.0, -0.5])

    def score_fn(x):
        return W @ x + b

    L = max(np.sum(np.abs(W[0] - W[1])), np.sum(np.abs(W[1] - W[0])))

    # Generate dataset
    dataset = [(np.random.randn(d), 0) for _ in range(100)]
    # Assign correct labels
    dataset = [(x, int(np.argmax(score_fn(x)))) for x, _ in dataset]

    epsilons = np.linspace(0, 0.5, 50)
    risks_hinge = [tropical_regularized_risk(score_fn, hinge_loss, dataset, L, e) for e in epsilons]
    risks_logistic = [tropical_regularized_risk(score_fn, logistic_loss, dataset, L, e) for e in epsilons]

    # Also compute certified accuracy at each epsilon
    cert_acc = []
    for eps in epsilons:
        certified = sum(1 for x, y in dataset
                       if certified_radius_from_lipschitz(score_fn, (x), y, L) >= eps)
        cert_acc.append(certified / len(dataset))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ax = axes[0]
    ax.plot(epsilons, risks_hinge, 'b-', linewidth=2, label='Hinge loss')
    ax.plot(epsilons, risks_logistic, 'r-', linewidth=2, label='Logistic loss')
    ax.set_xlabel('Perturbation Budget ε')
    ax.set_ylabel('Tropical Regularized Risk')
    ax.set_title('Tropical Risk vs. Perturbation Budget')
    ax.legend()
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.plot(epsilons, cert_acc, 'g-', linewidth=2)
    ax.set_xlabel('Perturbation Budget ε')
    ax.set_ylabel('Certified Accuracy')
    ax.set_title('Certified Accuracy vs. ε')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('application_tradeoff.png', dpi=150, bbox_inches='tight')
    print("  Saved: application_tradeoff.png")
    plt.close()


def application_3_multi_class_certificates():
    """
    Application 3: Multi-class certified radius computation.

    For a k-class classifier, the certified radius is the minimum
    pairwise margin divided by the Lipschitz constant.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Multi-Class Tropical Certificates")
    print("=" * 70)

    np.random.seed(456)
    d, c = 8, 5  # 8-dimensional, 5 classes

    W = np.random.randn(c, d) * 0.3
    b = np.zeros(c)

    def score_fn(x):
        return W @ x + b

    # Per-class pairwise Lipschitz constants
    L_pairwise = np.zeros((c, c))
    for i in range(c):
        for j in range(c):
            if i != j:
                L_pairwise[i, j] = np.sum(np.abs(W[i] - W[j]))

    L_global = np.max(L_pairwise)

    # Generate some test points
    n_test = 20
    print(f"\n  {'Point':>5s} | {'Label':>5s} | {'Margin':>8s} | {'Cert. Radius':>12s} | {'Min Pairwise':>12s}")
    print("  " + "-" * 55)

    for idx in range(n_test):
        x = np.random.randn(d) * 2
        scores = score_fn(x)
        y = int(np.argmax(scores))
        m = compute_margin(score_fn, x, y)
        r_global = max(0, m / L_global)

        # Per-class minimum pairwise radius
        pairwise_radii = []
        for j in range(c):
            if j != y and L_pairwise[y, j] > 0:
                gap = scores[y] - scores[j]
                pairwise_radii.append(gap / L_pairwise[y, j])
        r_pairwise = min(pairwise_radii) if pairwise_radii else 0

        print(f"  {idx:5d} | {y:5d} | {m:8.3f} | {r_global:12.4f} | {r_pairwise:12.4f}")


def application_4_depth_robustness():
    """
    Application 4: Depth-robustness tradeoff.

    Shows how the certified radius decreases with network depth
    due to Lipschitz constant growth — motivating tropical regularization.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Depth-Robustness Tradeoff")
    print("=" * 70)

    np.random.seed(789)
    d = 10
    depths = range(1, 11)

    mean_margins = []
    mean_radii = []
    lip_constants = []

    for depth in depths:
        # Simulate a depth-d network with random layers
        # Each layer has Lipschitz constant ~1.5
        layer_lip = 1.5
        total_lip = layer_lip ** depth

        # Generate random linear classifier with controlled Lipschitz constant
        W = np.random.randn(2, d)
        W = W / np.linalg.norm(W, axis=1, keepdims=True)  # Normalize

        def score_fn(x, _W=W):
            return _W @ x

        # Test points
        margins_here = []
        radii_here = []
        for _ in range(50):
            x = np.random.randn(d)
            scores = score_fn(x)
            y = int(np.argmax(scores))
            m = compute_margin(score_fn, x, y)
            margins_here.append(abs(m))
            radii_here.append(max(0, abs(m) / total_lip))

        mean_margins.append(np.mean(margins_here))
        mean_radii.append(np.mean(radii_here))
        lip_constants.append(total_lip)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    axes[0].semilogy(list(depths), lip_constants, 'ro-', linewidth=2)
    axes[0].set_xlabel('Network Depth')
    axes[0].set_ylabel('Lipschitz Constant')
    axes[0].set_title('Lipschitz Growth with Depth')
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(list(depths), mean_margins, 'bo-', linewidth=2)
    axes[1].set_xlabel('Network Depth')
    axes[1].set_ylabel('Mean Margin')
    axes[1].set_title('Margin vs. Depth')
    axes[1].grid(True, alpha=0.3)

    axes[2].semilogy(list(depths), mean_radii, 'go-', linewidth=2)
    axes[2].set_xlabel('Network Depth')
    axes[2].set_ylabel('Mean Certified Radius')
    axes[2].set_title('Certified Radius Shrinks with Depth')
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('application_depth_robustness.png', dpi=150, bbox_inches='tight')
    print("  Saved: application_depth_robustness.png")
    plt.close()

    print(f"\n  {'Depth':>5s} | {'Lip. Const.':>12s} | {'Mean Margin':>12s} | {'Mean Cert. Radius':>17s}")
    print("  " + "-" * 55)
    for depth, L, m, r in zip(depths, lip_constants, mean_margins, mean_radii):
        print(f"  {depth:5d} | {L:12.2f} | {m:12.4f} | {r:17.6f}")


if __name__ == "__main__":
    print("\n╔══════════════════════════════════════════════════════════════════════╗")
    print("║   TROPICAL ADVERSARIAL REGULARIZATION — APPLICATIONS               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝\n")

    application_1_certified_defense()
    application_2_robustness_accuracy_tradeoff()
    application_3_multi_class_certificates()
    application_4_depth_robustness()

    print("\n✓ All applications complete.")


#!/usr/bin/env python3
"""
Adversarial Training as Tropical Regularization — Demonstrations

Concrete numerical examples illustrating the three main theorems:
  A. Tropical distance = certified radius
  B. Robust loss ≤ tropical shift (min-plus erosion bound)
  C. Certified radius ≥ margin / Lipschitz constant

Uses a simple 2-class linear classifier on R^2 to make everything explicit.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from matplotlib.colors import LinearSegmentedColormap

# ──────────────────────────────────────────────────────────────────────
# Setup: 2-class linear classifier on R^2
# ──────────────────────────────────────────────────────────────────────

def score(W, b, x):
    """Score function: W @ x + b, shape (c,)."""
    return W @ x + b

def margin(W, b, x, y, c=2):
    """Classification margin for label y."""
    s = score(W, b, x)
    competitors = [s[j] for j in range(c) if j != y]
    return s[y] - max(competitors)

def robust_loss_empirical(W, b, x, y, phi, cost_fn, eps, n_samples=5000):
    """Monte Carlo estimate of robust loss = sup{phi(margin(x')) : cost(x,x') <= eps}."""
    d = len(x)
    best = phi(margin(W, b, x, y))
    for _ in range(n_samples):
        delta = np.random.uniform(-eps, eps, size=d)
        if cost_fn(x, x + delta) <= eps:
            val = phi(margin(W, b, x + delta, y))
            if val > best:
                best = val
        # Also try boundary points
        delta2 = np.random.randn(d)
        delta2 = delta2 / np.max(np.abs(delta2)) * eps
        if cost_fn(x, x + delta2) <= eps:
            val = phi(margin(W, b, x + delta2, y))
            if val > best:
                best = val
    return best

def linf_cost(x, xp):
    """L-infinity cost."""
    return np.max(np.abs(x - xp))

def hinge_loss(m):
    """Hinge loss: max(0, 1 - m). Antitone in m."""
    return max(0.0, 1.0 - m)

# ──────────────────────────────────────────────────────────────────────
# Demo 1: Theorem B — Robust loss ≤ tropical shift
# ──────────────────────────────────────────────────────────────────────

def demo_theorem_b():
    """Demonstrate that robust loss ≤ φ(margin - L*ε)."""
    print("=" * 70)
    print("DEMO 1: Theorem B — Robust Loss ≤ Tropical Shift")
    print("=" * 70)

    # Simple 2-class classifier in R^2
    W = np.array([[1.0, 0.5], [-0.5, 1.0]])  # weight matrix (c x d)
    b = np.array([0.0, -1.0])                  # bias

    # The margin Lipschitz constant: for linear score, margin(x') - margin(x)
    # depends on the weight differences. L = max norm of weight differences.
    # For Linf cost, L = sum of |W[y,i] - W[j,i]| for worst j.
    L = np.sum(np.abs(W[0] - W[1]))  # = |1-(-0.5)| + |0.5-1| = 1.5 + 0.5 = 2.0
    print(f"  Weight matrix W = {W.tolist()}")
    print(f"  Bias b = {b.tolist()}")
    print(f"  Margin Lipschitz constant L = {L}")

    # Dataset
    points = [
        (np.array([2.0, 1.0]), 0),
        (np.array([1.0, 0.5]), 0),
        (np.array([0.5, 0.3]), 0),
        (np.array([3.0, 2.0]), 0),
    ]

    epsilons = [0.0, 0.1, 0.2, 0.3, 0.5]

    print(f"\n  {'Point':>12s} | {'ε':>5s} | {'margin':>8s} | {'Robust Loss':>12s} | {'φ(m-Lε)':>10s} | {'Bound?':>6s}")
    print("  " + "-" * 68)

    for x, y in points:
        m = margin(W, b, x, y)
        for eps in epsilons:
            rl = robust_loss_empirical(W, b, x, y, hinge_loss, linf_cost, eps)
            tropical_bound = hinge_loss(m - L * eps)
            holds = "✓" if rl <= tropical_bound + 1e-6 else "✗"
            print(f"  {str(x):>12s} | {eps:5.2f} | {m:8.3f} | {rl:12.4f} | {tropical_bound:10.4f} | {holds:>6s}")
        print()

    return W, b, L, points

# ──────────────────────────────────────────────────────────────────────
# Demo 2: Theorem C — Certified radius ≥ margin / L
# ──────────────────────────────────────────────────────────────────────

def demo_theorem_c(W, b, L, points):
    """Demonstrate certified radius lower bound."""
    print("=" * 70)
    print("DEMO 2: Theorem C — Certified Radius ≥ margin / L")
    print("=" * 70)

    print(f"\n  {'Point':>12s} | {'margin':>8s} | {'margin/L':>8s} | {'Empirical cert. radius':>22s} | {'Bound?':>6s}")
    print("  " + "-" * 68)

    for x, y in points:
        m = margin(W, b, x, y)
        theoretical_radius = m / L if m > 0 else 0

        # Empirically find certified radius: largest eps where margin stays positive
        cert_radius = 0.0
        for eps_test in np.linspace(0, theoretical_radius * 2, 200):
            all_positive = True
            for _ in range(1000):
                delta = np.random.uniform(-eps_test, eps_test, size=len(x))
                if linf_cost(x, x + delta) <= eps_test:
                    if margin(W, b, x + delta, y) <= 0:
                        all_positive = False
                        break
            if all_positive:
                cert_radius = eps_test
            else:
                break

        holds = "✓" if cert_radius >= theoretical_radius - 0.05 else "~"
        print(f"  {str(x):>12s} | {m:8.3f} | {theoretical_radius:8.3f} | {cert_radius:22.3f} | {holds:>6s}")

# ──────────────────────────────────────────────────────────────────────
# Demo 3: Empirical risk bound
# ──────────────────────────────────────────────────────────────────────

def demo_empirical_risk(W, b, L, points):
    """Demonstrate dataset-level bound: robust risk ≤ Σ φ(margin - L*ε)."""
    print("\n" + "=" * 70)
    print("DEMO 3: Robust Empirical Risk ≤ Tropical Regularized Risk")
    print("=" * 70)

    epsilons = [0.0, 0.1, 0.2, 0.3, 0.5]
    print(f"\n  {'ε':>5s} | {'Robust ERM':>12s} | {'Trop. Reg. Risk':>15s} | {'Bound?':>6s}")
    print("  " + "-" * 48)

    for eps in epsilons:
        robust_risk = sum(
            robust_loss_empirical(W, b, x, y, hinge_loss, linf_cost, eps)
            for x, y in points
        )
        trop_risk = sum(
            hinge_loss(margin(W, b, x, y) - L * eps)
            for x, y in points
        )
        holds = "✓" if robust_risk <= trop_risk + 1e-4 else "✗"
        print(f"  {eps:5.2f} | {robust_risk:12.4f} | {trop_risk:15.4f} | {holds:>6s}")

# ──────────────────────────────────────────────────────────────────────
# Demo 4: Tropical distance to adversarial set
# ──────────────────────────────────────────────────────────────────────

def demo_tropical_distance(W, b, L):
    """Visualize the tropical distance field and adversarial set."""
    print("\n" + "=" * 70)
    print("DEMO 4: Tropical Distance Field Visualization")
    print("=" * 70)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Grid
    x_range = np.linspace(-2, 4, 200)
    y_range = np.linspace(-2, 4, 200)
    X, Y = np.meshgrid(x_range, y_range)

    # Compute margin field for label 0
    margin_field = np.zeros_like(X)
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            pt = np.array([X[i, j], Y[i, j]])
            margin_field[i, j] = margin(W, b, pt, 0)

    # Panel 1: Margin field
    ax = axes[0]
    cmap = LinearSegmentedColormap.from_list('margin', ['red', 'white', 'blue'])
    vmax = max(abs(margin_field.min()), abs(margin_field.max()))
    im = ax.contourf(X, Y, margin_field, levels=50, cmap=cmap, vmin=-vmax, vmax=vmax)
    ax.contour(X, Y, margin_field, levels=[0], colors='black', linewidths=2)
    ax.set_title('Classification Margin m(x, y=0)', fontsize=12)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    plt.colorbar(im, ax=ax)

    # Panel 2: Adversarial set and tropical distance
    ax = axes[1]
    # Adversarial set: margin ≤ 0
    adv_mask = margin_field <= 0
    ax.contourf(X, Y, adv_mask.astype(float), levels=[0.5, 1.5], colors=['red'], alpha=0.3)
    ax.contour(X, Y, margin_field, levels=[0], colors='black', linewidths=2)

    # Show certified radius circles for a few points
    test_points = [np.array([2.0, 1.0]), np.array([1.0, 0.5]), np.array([3.0, 2.0])]
    for pt in test_points:
        m = margin(W, b, pt, 0)
        if m > 0:
            r = m / L
            circle = Circle(pt, r, fill=False, color='green', linewidth=2, linestyle='--')
            ax.add_patch(circle)
            ax.plot(*pt, 'go', markersize=8)
            ax.annotate(f'r={r:.2f}', pt + np.array([0.1, 0.1]), fontsize=9, color='green')

    ax.set_title('Adversarial Set (red) & Certified Radii', fontsize=12)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_xlim(-2, 4)
    ax.set_ylim(-2, 4)

    # Panel 3: Tropical regularized loss landscape
    ax = axes[2]
    eps_values = [0, 0.1, 0.3, 0.5]
    margins_range = np.linspace(-2, 3, 300)
    for eps in eps_values:
        losses = [hinge_loss(m - L * eps) for m in margins_range]
        ax.plot(margins_range, losses, label=f'φ(m - {L}·{eps})', linewidth=2)
    ax.set_xlabel('Margin m')
    ax.set_ylabel('Loss')
    ax.set_title('Tropical Erosion of Hinge Loss', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_adversarial_visualization.png', dpi=150, bbox_inches='tight')
    print("  Saved: tropical_adversarial_visualization.png")
    plt.close()

# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n╔══════════════════════════════════════════════════════════════════════╗")
    print("║   ADVERSARIAL TRAINING AS TROPICAL REGULARIZATION — DEMOS          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝\n")

    W, b, L, points = demo_theorem_b()
    demo_theorem_c(W, b, L, points)
    demo_empirical_risk(W, b, L, points)
    demo_tropical_distance(W, b, L)

    print("\n✓ All demonstrations complete.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables bundled."""

import json
import base64

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_image_base64(path):
    with open(path, 'rb') as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode('utf-8')

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('MachineLearning/TropicalAdversarialRegularization.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read images
viz1 = read_image_base64('tropical_adversarial_visualization.png')
viz2 = read_image_base64('application_certified_defense.png')
viz3 = read_image_base64('application_tradeoff.png')
viz4 = read_image_base64('application_depth_robustness.png')

package = {
    "title": "Adversarial Training as Tropical Regularization: Provable Defense via Min-Plus Algebra",
    "domain": "Machine Learning / Tropical Geometry / Certified Robustness",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Adversarial Regularization — Full Demo",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "TropicalCertify — Certified Radius Computation",
            "pseudocode": (
                "Input: score function s, point x, label y, Lipschitz constant L\n"
                "Output: certified robustness radius r\n\n"
                "1. Compute score vector: v ← s(x, ·)           // O(c)\n"
                "2. Compute margin: m ← v[y] - max_{j≠y} v[j]   // O(c)\n"
                "3. If m ≤ 0: return 0\n"
                "4. Return m / L                                  // O(1)\n\n"
                "Complexity: O(c) per point"
            ),
            "code": algorithms_code
        },
        {
            "name": "TropicalRisk — Tropical Regularized Empirical Risk",
            "pseudocode": (
                "Input: score function s, dataset S, loss φ, Lipschitz constant L, budget ε\n"
                "Output: tropical regularized risk R\n\n"
                "1. R ← 0\n"
                "2. For each (x_i, y_i) in S:\n"
                "   a. m_i ← margin(s, x_i, y_i)\n"
                "   b. R ← R + φ(m_i - L·ε)\n"
                "3. Return R / |S|\n\n"
                "Complexity: O(m·c) total"
            ),
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Adversarial Visualization (Margin Field, Adversarial Set, Erosion)",
            "data": viz1
        },
        {
            "name": "Certified Defense: Radius Distribution and Margin-Radius Relationship",
            "data": viz2
        },
        {
            "name": "Robustness-Accuracy Tradeoff via Tropical Regularization",
            "data": viz3
        },
        {
            "name": "Depth-Robustness Tradeoff: Lipschitz Growth and Certified Radius Decay",
            "data": viz4
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
print(f"  Size: {len(json.dumps(package)):,} bytes")
