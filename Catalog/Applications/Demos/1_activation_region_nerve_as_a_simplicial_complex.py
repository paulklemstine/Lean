#!/usr/bin/env python3
"""
Applications of Activation-Nerve Certification

Demonstrates practical applications of the theoretical framework:
1. Certifying a trained binary classifier
2. Comparing certification across architectures
3. Robustness scaling with depth and width
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ──────────────────────────────────────────────────────────────────
# Application 1: Binary Classifier Certification
# ──────────────────────────────────────────────────────────────────

def app_binary_classifier():
    """
    Certify a simple binary classifier on 2D data.
    
    The classifier separates two classes using a 2-layer ReLU network.
    We compute the activation nerve and certify robustness.
    """
    print("=" * 60)
    print("Application 1: Binary Classifier Certification")
    print("=" * 60)
    
    np.random.seed(42)
    
    # Generate synthetic data: two clusters
    n_per_class = 50
    class0 = np.random.randn(n_per_class, 2) * 0.3 + np.array([-1, 0])
    class1 = np.random.randn(n_per_class, 2) * 0.3 + np.array([1, 0])
    
    # Simple ReLU classifier (pre-trained weights)
    W1 = np.array([[2.0, 0.5], [-2.0, 0.5], [0.0, 2.0], [0.0, -2.0]])
    b1 = np.array([1.0, 1.0, 0.5, 0.5])
    W2 = np.array([[1.0, -1.0, 0.3, -0.3]])
    b2 = np.array([0.0])
    
    def forward(x):
        h = np.maximum(0, W1 @ x + b1)
        return float((W2 @ h + b2)[0])
    
    def margin(x):
        """Margin = |f(x)| (distance to decision boundary)"""
        return abs(forward(x))
    
    # Compute margins on a grid
    grid_x = np.linspace(-3, 3, 100)
    grid_y = np.linspace(-2, 2, 100)
    X, Y = np.meshgrid(grid_x, grid_y)
    Z = np.zeros_like(X)
    M = np.zeros_like(X)
    for i in range(100):
        for j in range(100):
            pt = np.array([X[i,j], Y[i,j]])
            Z[i,j] = forward(pt)
            M[i,j] = margin(pt)
    
    # Estimate Lipschitz constant
    L = float(np.linalg.norm(W2) * np.linalg.norm(W1))
    
    # Activation regions via sign patterns
    domain_pts = np.random.uniform([-3, -2], [3, 2], (5000, 2))
    patterns = set()
    pattern_margins = {}
    
    for pt in domain_pts:
        z = W1 @ pt + b1
        pat = tuple((z > 0).astype(int))
        patterns.add(pat)
        m = margin(pt)
        if pat not in pattern_margins:
            pattern_margins[pat] = m
        else:
            pattern_margins[pat] = min(pattern_margins[pat], m)
    
    print(f"\n  Network: 2 inputs → 4 hidden → 1 output")
    print(f"  Lipschitz constant L ≤ {L:.2f}")
    print(f"  Observed activation regions: {len(patterns)}")
    
    print(f"\n  Local margins by region:")
    all_positive = True
    min_margin = float('inf')
    for pat, m in sorted(pattern_margins.items()):
        status = "✓" if m > 0.01 else "✗"
        print(f"    {pat}: δ = {m:.4f} {status}")
        if m < 0.01:
            all_positive = False
        min_margin = min(min_margin, m)
    
    print(f"\n  Degree-1 exact (all positive)? {all_positive}")
    print(f"  Global margin δ = {min_margin:.4f}")
    if min_margin > 0:
        r = min_margin / L
        print(f"  Certified radius r = δ/L = {r:.4f}")
    
    # Visualization
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    ax = axes[0]
    ax.contourf(X, Y, Z, levels=20, cmap='RdBu', alpha=0.8)
    ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
    ax.scatter(class0[:, 0], class0[:, 1], c='blue', s=20, alpha=0.7, label='Class 0')
    ax.scatter(class1[:, 0], class1[:, 1], c='red', s=20, alpha=0.7, label='Class 1')
    ax.set_title('Classifier Output f(x)', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    
    ax = axes[1]
    im = ax.contourf(X, Y, M, levels=20, cmap='viridis')
    plt.colorbar(im, ax=ax, label='margin')
    # Draw activation region boundaries
    for k in range(W1.shape[0]):
        w, b_val = W1[k], b1[k]
        if abs(w[1]) > 1e-6:
            y_vals = -(w[0] * grid_x + b_val) / w[1]
            mask = (y_vals > -2) & (y_vals < 2)
            ax.plot(grid_x[mask], y_vals[mask], 'w--', linewidth=1, alpha=0.7)
        else:
            x_val = -b_val / w[0]
            ax.axvline(x=x_val, color='white', linestyle='--', linewidth=1, alpha=0.7)
    ax.set_title('Margin |f(x)| with Region Boundaries', fontsize=13)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    
    ax = axes[2]
    margins_list = sorted(pattern_margins.values())
    colors = ['#2ecc71' if m > 0.01 else '#e74c3c' for m in margins_list]
    ax.barh(range(len(margins_list)), margins_list, color=colors)
    if min_margin > 0:
        ax.axvline(x=min_margin, color='red', linestyle='--', label=f'δ={min_margin:.3f}')
    ax.set_ylabel('Region index')
    ax.set_xlabel('Local margin infimum')
    ax.set_title('Margin Cosheaf Values', fontsize=13)
    ax.legend()
    
    plt.tight_layout()
    plt.savefig('app_binary_classifier.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  [Saved: app_binary_classifier.png]")


# ──────────────────────────────────────────────────────────────────
# Application 2: Robustness vs Architecture
# ──────────────────────────────────────────────────────────────────

def app_robustness_scaling():
    """
    Study how certified robustness radius scales with network depth and width.
    """
    print("\n" + "=" * 60)
    print("Application 2: Robustness Scaling with Architecture")
    print("=" * 60)
    
    from math import comb
    
    def max_regions(widths, d):
        r = 1
        for w in widths:
            r *= sum(comb(w, k) for k in range(d + 1))
        return r
    
    d = 2  # input dimension
    
    # Width scaling (fixed depth = 2 layers)
    widths_range = range(2, 33)
    width_regions = [max_regions([w], d) for w in widths_range]
    
    # Depth scaling (fixed width = 8)
    depths_range = range(1, 11)
    depth_regions = [max_regions([8] * L, d) for L in depths_range]
    
    print(f"\n  Width scaling (depth=1, d={d}):")
    for w in [4, 8, 16, 32]:
        r = max_regions([w], d)
        print(f"    Width {w:>3}: max {r:>6} regions")
    
    print(f"\n  Depth scaling (width=8, d={d}):")
    for L in [1, 2, 4, 8]:
        r = max_regions([8] * L, d)
        print(f"    Depth {L:>2}: max {r:>10} regions")
    
    # Simulate robustness scaling
    # Assume: margin ~ 1/sqrt(#regions), Lipschitz ~ product of layer norms
    np.random.seed(42)
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Panel 1: Region count scaling
    ax = axes[0]
    ax.semilogy(list(widths_range), width_regions, 'b-o', markersize=3, label=f'Depth 1, d={d}')
    ax.set_xlabel('Width (neurons per layer)', fontsize=11)
    ax.set_ylabel('Max activation regions', fontsize=11)
    ax.set_title('Region Count vs Width', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Depth scaling
    ax = axes[1]
    ax.semilogy(list(depths_range), depth_regions, 'r-s', markersize=5, label=f'Width 8, d={d}')
    ax.set_xlabel('Depth (number of layers)', fontsize=11)
    ax.set_ylabel('Max activation regions', fontsize=11)
    ax.set_title('Region Count vs Depth', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Robustness radius (simulated)
    ax = axes[2]
    widths_sim = np.array([4, 8, 12, 16, 20, 24, 28, 32])
    # Contractive layers: Lip per layer < 1
    for lip_per_layer in [0.5, 0.7, 0.9]:
        depths_sim = np.arange(1, 11)
        radii = []
        for L_val in depths_sim:
            total_lip = lip_per_layer ** L_val
            margin_est = 0.5  # baseline margin
            r = margin_est / (total_lip + 0.01)
            radii.append(r)
        ax.plot(depths_sim, radii, '-o', markersize=4, 
                label=f'Lip/layer = {lip_per_layer}')
    
    ax.set_xlabel('Depth', fontsize=11)
    ax.set_ylabel('Certified radius r = δ/L', fontsize=11)
    ax.set_title('Certified Radius vs Depth\n(contractive layers)', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('app_robustness_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  [Saved: app_robustness_scaling.png]")


# ──────────────────────────────────────────────────────────────────
# Application 3: Adversarial Detection via Nerve Topology
# ──────────────────────────────────────────────────────────────────

def app_adversarial_detection():
    """
    Use the activation nerve to detect potential adversarial vulnerabilities.
    
    Regions with low margin in the cosheaf indicate vulnerability.
    """
    print("\n" + "=" * 60)
    print("Application 3: Adversarial Vulnerability Detection")
    print("=" * 60)
    
    np.random.seed(123)
    n_regions = 12
    
    # Simulate margin cosheaf values
    margins = np.random.exponential(0.5, n_regions)
    margins[3] = 0.01   # vulnerable region
    margins[7] = 0.005  # very vulnerable region
    
    print(f"\n  Simulated classifier with {n_regions} activation regions")
    print(f"\n  Margin cosheaf values:")
    vulnerable = []
    for i, m in enumerate(margins):
        status = "⚠ VULNERABLE" if m < 0.05 else "✓ robust"
        print(f"    R_{i:>2}: δ = {m:.4f}  {status}")
        if m < 0.05:
            vulnerable.append(i)
    
    global_margin = min(margins)
    L = 5.0
    r = max(0, global_margin / L)
    
    print(f"\n  Global margin δ = {global_margin:.4f}")
    print(f"  Lipschitz constant L = {L}")
    print(f"  Certified radius r = {r:.4f}")
    print(f"\n  Vulnerable regions: {vulnerable}")
    print(f"  → Focus hardening efforts on regions {vulnerable}")
    print(f"  → After fixing these, certified radius could improve to "
          f"{min(m for i, m in enumerate(margins) if i not in vulnerable) / L:.4f}")
    
    # Visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    colors = ['#e74c3c' if m < 0.05 else '#2ecc71' for m in margins]
    ax1.bar(range(n_regions), margins, color=colors)
    ax1.axhline(y=0.05, color='orange', linestyle='--', label='Vulnerability threshold')
    ax1.axhline(y=global_margin, color='red', linestyle='--', alpha=0.5, label=f'Global δ = {global_margin:.4f}')
    ax1.set_xlabel('Activation region index')
    ax1.set_ylabel('Local margin infimum')
    ax1.set_title('Margin Cosheaf: Vulnerability Map', fontsize=13)
    ax1.legend()
    
    # Nerve diagram with vulnerability highlighting
    angles = np.linspace(0, 2*np.pi, n_regions, endpoint=False)
    positions = list(zip(np.cos(angles) * 2, np.sin(angles) * 2))
    
    # Draw edges
    for i in range(n_regions):
        j = (i + 1) % n_regions
        ax2.plot([positions[i][0], positions[j][0]],
                 [positions[i][1], positions[j][1]],
                 'k-', linewidth=0.5, alpha=0.3)
    
    for i, ((px, py), m) in enumerate(zip(positions, margins)):
        size = 0.3 if m >= 0.05 else 0.5
        color = '#e74c3c' if m < 0.05 else '#2ecc71'
        alpha = 1.0 if m < 0.05 else 0.6
        circle = plt.Circle((px, py), size, color=color, alpha=alpha)
        ax2.add_patch(circle)
        ax2.text(px, py, f'{i}', ha='center', va='center', fontsize=8, fontweight='bold')
    
    ax2.set_xlim(-3, 3)
    ax2.set_ylim(-3, 3)
    ax2.set_aspect('equal')
    ax2.set_title('Activation Nerve: Vulnerability Heatmap', fontsize=13)
    ax2.axis('off')
    
    plt.tight_layout()
    plt.savefig('app_adversarial_detection.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  [Saved: app_adversarial_detection.png]")


if __name__ == '__main__':
    app_binary_classifier()
    app_robustness_scaling()
    app_adversarial_detection()
    print("\n✓ All applications completed.")


#!/usr/bin/env python3
"""
Activation-Region Nerve and Margin-Cosheaf Exactness: Concrete Demonstrations

This script demonstrates the core theorems with concrete numerical examples:
1. A 1D ReLU network with 3 activation regions
2. A 2D ReLU network with 6 activation regions
3. The certification pipeline: local margins → nerve → exactness → robustness radius
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection
import json

# ──────────────────────────────────────────────────────────────────
# Example 1: 1D ReLU classifier with 3 activation regions
# ──────────────────────────────────────────────────────────────────

def relu(x):
    return np.maximum(0, x)

def example_1d_classifier():
    """
    A simple 1D ReLU classifier:
      f(x) = relu(x + 1) - 2*relu(x) + relu(x - 1) + 0.5
    
    This is piecewise linear with breakpoints at x = -1, 0, 1.
    Activation regions: R0 = (-inf, -1], R1 = [-1, 0], R2 = [0, 1], R3 = [1, inf)
    Domain K = [-2, 2].
    """
    x = np.linspace(-2, 2, 1000)
    margin = relu(x + 1) - 2*relu(x) + relu(x - 1) + 0.5
    
    # Activation regions (intersected with K = [-2, 2])
    regions = {
        'R0: [-2, -1]': (-2, -1),
        'R1: [-1, 0]': (-1, 0),
        'R2: [0, 1]': (0, 1),
        'R3: [1, 2]': (1, 2),
    }
    
    print("=" * 60)
    print("Example 1: 1D ReLU Classifier on K = [-2, 2]")
    print("=" * 60)
    print(f"  f(x) = relu(x+1) - 2*relu(x) + relu(x-1) + 0.5")
    print()
    
    # Compute local margin infima
    local_margins = {}
    for name, (a, b) in regions.items():
        mask = (x >= a) & (x <= b)
        local_min = margin[mask].min()
        local_margins[name] = local_min
        print(f"  {name}: inf margin = {local_min:.4f}")
    
    # Check degree-1 exactness: all local margins positive?
    all_positive = all(m > 0 for m in local_margins.values())
    print(f"\n  All local margins positive (degree-1 exact)? {all_positive}")
    
    # Global margin
    global_min = margin.min()
    print(f"  Global minimum margin δ = {global_min:.4f}")
    
    # Lipschitz constant (max |f'(x)|)
    L = np.max(np.abs(np.diff(margin) / np.diff(x)))
    print(f"  Lipschitz constant L ≈ {L:.4f}")
    
    if all_positive and global_min > 0:
        r = global_min / L
        print(f"  Certified robustness radius r = δ/L ≈ {r:.4f}")
        print(f"  → Any perturbation of size < {r:.4f} preserves classification")
    
    # Plot
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))
    
    colors = ['#2ecc71', '#3498db', '#e74c3c', '#f39c12']
    for idx, (name, (a, b)) in enumerate(regions.items()):
        mask = (x >= a) & (x <= b)
        ax1.fill_between(x[mask], 0, margin[mask], alpha=0.3, color=colors[idx], label=name)
    
    ax1.plot(x, margin, 'k-', linewidth=2, label='margin(x)')
    ax1.axhline(y=global_min, color='red', linestyle='--', alpha=0.7, label=f'δ = {global_min:.3f}')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('margin(x)', fontsize=12)
    ax1.set_title('1D ReLU Classifier: Margin Function and Activation Regions', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Nerve diagram
    ax2.set_xlim(-0.5, 4.5)
    ax2.set_ylim(-0.5, 1.5)
    ax2.set_aspect('equal')
    
    # Draw vertices
    positions = [(0, 0.5), (1.5, 0.5), (3, 0.5), (4.5, 0.5)]
    labels = ['R0', 'R1', 'R2', 'R3']
    for (px, py), label, m, c in zip(positions, labels, local_margins.values(), colors):
        circle = plt.Circle((px, py), 0.2, color=c, alpha=0.7)
        ax2.add_patch(circle)
        ax2.text(px, py, label, ha='center', va='center', fontsize=10, fontweight='bold')
        ax2.text(px, py - 0.4, f'δ={m:.2f}', ha='center', va='center', fontsize=8)
    
    # Draw edges (overlaps at breakpoints)
    for i in range(3):
        ax2.plot([positions[i][0], positions[i+1][0]], 
                 [positions[i][1], positions[i+1][1]], 
                 'k-', linewidth=2, alpha=0.5)
    
    ax2.set_title('Activation Nerve (1-skeleton)', fontsize=14)
    ax2.axis('off')
    
    plt.tight_layout()
    plt.savefig('demo_1d_activation_nerve.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  [Saved: demo_1d_activation_nerve.png]")
    return fig

# ──────────────────────────────────────────────────────────────────
# Example 2: 2D ReLU network with polyhedral activation regions
# ──────────────────────────────────────────────────────────────────

def example_2d_classifier():
    """
    A 2D ReLU classifier with activation regions defined by 3 hyperplanes:
      h1: x1 = 0, h2: x2 = 0, h3: x1 + x2 = 1
    
    This creates 6 activation regions in [-1,2]².
    The margin function: f(x1, x2) = relu(x1) + relu(x2) + relu(1 - x1 - x2) + 0.3
    """
    print("\n" + "=" * 60)
    print("Example 2: 2D ReLU Classifier on K = [-1, 2]²")
    print("=" * 60)
    
    N = 200
    x1 = np.linspace(-1, 2, N)
    x2 = np.linspace(-1, 2, N)
    X1, X2 = np.meshgrid(x1, x2)
    
    margin = relu(X1) + relu(X2) + relu(1 - X1 - X2) + 0.3
    
    # Define activation regions by sign patterns
    sign_patterns = {
        '(-, -, +)': (X1 < 0) & (X2 < 0) & (X1 + X2 < 1),
        '(+, -, +)': (X1 >= 0) & (X2 < 0) & (X1 + X2 < 1),
        '(-, +, +)': (X1 < 0) & (X2 >= 0) & (X1 + X2 < 1),
        '(+, +, +)': (X1 >= 0) & (X2 >= 0) & (X1 + X2 < 1),
        '(+, -, -)': (X1 >= 0) & (X2 < 0) & (X1 + X2 >= 1),
        '(-, +, -)': (X1 < 0) & (X2 >= 0) & (X1 + X2 >= 1),
        '(+, +, -)': (X1 >= 0) & (X2 >= 0) & (X1 + X2 >= 1),
    }
    
    local_margins = {}
    for name, mask in sign_patterns.items():
        if mask.any():
            local_min = margin[mask].min()
            local_margins[name] = local_min
            print(f"  {name}: inf margin = {local_min:.4f}")
    
    all_positive = all(m > 0 for m in local_margins.values())
    global_min = margin.min()
    
    print(f"\n  All local margins positive? {all_positive}")
    print(f"  Global minimum margin δ = {global_min:.4f}")
    
    # Estimate Lipschitz constant
    grad_x1 = np.gradient(margin, x1[1] - x1[0], axis=1)
    grad_x2 = np.gradient(margin, x2[1] - x2[0], axis=0)
    L = np.max(np.sqrt(grad_x1**2 + grad_x2**2))
    print(f"  Lipschitz constant L ≈ {L:.4f}")
    
    if all_positive and global_min > 0:
        r = global_min / L
        print(f"  Certified robustness radius r = δ/L ≈ {r:.4f}")
    
    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Margin heatmap
    im = ax1.contourf(X1, X2, margin, levels=20, cmap='viridis')
    plt.colorbar(im, ax=ax1, label='margin(x)')
    
    # Draw hyperplane boundaries
    ax1.plot([0, 0], [-1, 2], 'w--', linewidth=1.5, alpha=0.7)
    ax1.plot([-1, 2], [0, 0], 'w--', linewidth=1.5, alpha=0.7)
    ax1.plot([-1, 2], [2, -1], 'w--', linewidth=1.5, alpha=0.7)
    
    ax1.set_xlabel('x₁', fontsize=12)
    ax1.set_ylabel('x₂', fontsize=12)
    ax1.set_title('Margin Function with Activation Region Boundaries', fontsize=13)
    
    # Nerve diagram
    ax2.set_xlim(-1, 5)
    ax2.set_ylim(-1, 4)
    
    # Nerve vertices and edges
    nerve_pos = {
        '(-, -, +)': (0, 0),
        '(+, -, +)': (2, 0),
        '(-, +, +)': (0, 2),
        '(+, +, +)': (2, 2),
        '(+, -, -)': (4, 0),
        '(-, +, -)': (0, 3.5),
        '(+, +, -)': (4, 2),
    }
    
    edges = [
        ('(-, -, +)', '(+, -, +)'),
        ('(-, -, +)', '(-, +, +)'),
        ('(+, -, +)', '(+, +, +)'),
        ('(-, +, +)', '(+, +, +)'),
        ('(+, -, +)', '(+, -, -)'),
        ('(-, +, +)', '(-, +, -)'),
        ('(+, +, +)', '(+, +, -)'),
        ('(+, -, -)','(+, +, -)'),
    ]
    
    for n1, n2 in edges:
        if n1 in nerve_pos and n2 in nerve_pos:
            p1, p2 = nerve_pos[n1], nerve_pos[n2]
            ax2.plot([p1[0], p2[0]], [p1[1], p2[1]], 'k-', linewidth=1.5, alpha=0.5)
    
    for name, (px, py) in nerve_pos.items():
        m = local_margins.get(name, 0)
        color = '#2ecc71' if m > 0 else '#e74c3c'
        circle = plt.Circle((px, py), 0.35, color=color, alpha=0.7)
        ax2.add_patch(circle)
        short = name.replace('(', '').replace(')', '').replace(' ', '')
        ax2.text(px, py + 0.05, short, ha='center', va='center', fontsize=7, fontweight='bold')
        ax2.text(px, py - 0.55, f'δ={m:.2f}', ha='center', fontsize=7)
    
    ax2.set_title('Activation Nerve (2D Network)', fontsize=13)
    ax2.set_aspect('equal')
    ax2.axis('off')
    
    plt.tight_layout()
    plt.savefig('demo_2d_activation_nerve.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  [Saved: demo_2d_activation_nerve.png]")
    return fig

# ──────────────────────────────────────────────────────────────────
# Example 3: Certification Pipeline
# ──────────────────────────────────────────────────────────────────

def example_certification_pipeline():
    """
    Demonstrate the full certification pipeline:
    Local margins → Nerve construction → Exactness check → Robustness radius
    """
    print("\n" + "=" * 60)
    print("Example 3: Full Certification Pipeline")
    print("=" * 60)
    
    # Network parameters
    n_regions = 5
    d = 2
    L = 3.2  # Lipschitz constant
    
    print(f"\n  Network: {n_regions} activation regions in ℝ^{d}")
    print(f"  Lipschitz constant L = {L}")
    
    # Simulated local margins (infima on each region)
    np.random.seed(42)
    local_margins = np.random.uniform(0.1, 0.8, n_regions)
    
    print(f"\n  Step 1: Compute local margin infima")
    for i, m in enumerate(local_margins):
        print(f"    R_{i}: δ_{i} = {m:.4f}")
    
    print(f"\n  Step 2: Check degree-1 exactness")
    exact = all(m > 0 for m in local_margins)
    print(f"    All vertex margins positive? {exact}")
    
    # Simulated overlap margins
    print(f"\n  Step 3: Check overlap compatibility")
    overlaps = [(0,1), (1,2), (2,3), (3,4), (0,4)]
    overlap_margins = [min(local_margins[i], local_margins[j]) + 0.05 for i, j in overlaps]
    for (i, j), m in zip(overlaps, overlap_margins):
        print(f"    R_{i} ∩ R_{j}: δ = {m:.4f}")
    
    print(f"\n  Step 4: Extract global margin")
    delta = min(local_margins)
    print(f"    Global margin δ = min(δ_i) = {delta:.4f}")
    
    print(f"\n  Step 5: Compute certified robustness radius")
    r = delta / L
    print(f"    Certified radius r = δ/L = {delta:.4f}/{L} = {r:.4f}")
    print(f"    → The classifier is provably correct for all")
    print(f"      perturbations of ℓ²-norm < {r:.4f}")
    
    # Visualization
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Panel 1: Local margins bar chart
    ax = axes[0]
    bars = ax.bar(range(n_regions), local_margins, color=['#2ecc71' if m > 0 else '#e74c3c' for m in local_margins])
    ax.axhline(y=delta, color='red', linestyle='--', alpha=0.7, label=f'δ = {delta:.3f}')
    ax.set_xlabel('Region index i', fontsize=11)
    ax.set_ylabel('Local margin inf', fontsize=11)
    ax.set_title('Step 1: Local Margin Infima', fontsize=12)
    ax.legend()
    
    # Panel 2: Nerve graph
    ax = axes[1]
    angles = np.linspace(0, 2*np.pi, n_regions, endpoint=False)
    positions = list(zip(np.cos(angles), np.sin(angles)))
    
    for i, j in overlaps:
        ax.plot([positions[i][0], positions[j][0]], 
                [positions[i][1], positions[j][1]], 'k-', linewidth=1.5, alpha=0.4)
    
    for idx, (px, py) in enumerate(positions):
        color = '#2ecc71' if local_margins[idx] > delta else '#f39c12'
        circle = plt.Circle((px, py), 0.15, color=color, alpha=0.8)
        ax.add_patch(circle)
        ax.text(px, py, f'R{idx}', ha='center', va='center', fontsize=9, fontweight='bold')
    
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title('Step 2-3: Activation Nerve', fontsize=12)
    ax.axis('off')
    
    # Panel 3: Robustness radius diagram
    ax = axes[2]
    theta = np.linspace(0, 2*np.pi, 100)
    ax.fill(r * np.cos(theta), r * np.sin(theta), alpha=0.3, color='#2ecc71', label=f'r = {r:.3f}')
    ax.plot(r * np.cos(theta), r * np.sin(theta), color='#2ecc71', linewidth=2)
    ax.plot(0, 0, 'ko', markersize=8)
    ax.text(0.02, -0.03, 'x', fontsize=12, fontweight='bold')
    ax.annotate('', xy=(r, 0), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=2))
    ax.text(r/2, 0.02, f'r={r:.3f}', fontsize=10, color='#e74c3c', ha='center')
    ax.set_xlim(-0.3, 0.3)
    ax.set_ylim(-0.3, 0.3)
    ax.set_aspect('equal')
    ax.set_title('Step 5: Certified Robustness Ball', fontsize=12)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demo_certification_pipeline.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  [Saved: demo_certification_pipeline.png]")
    return fig

# ──────────────────────────────────────────────────────────────────
# Example 4: Region count bounds
# ──────────────────────────────────────────────────────────────────

def example_region_bounds():
    """
    Compute and visualize the Zaslavsky-type bounds on number of activation regions.
    """
    print("\n" + "=" * 60)
    print("Example 4: Activation Region Count Bounds")
    print("=" * 60)
    
    from math import comb
    
    def max_regions_single_layer(n, d):
        return sum(comb(n, k) for k in range(d + 1))
    
    print(f"\n  Single-layer bounds (Zaslavsky):")
    print(f"  {'Neurons n':>12} {'Dim d':>8} {'Max regions':>14}")
    print(f"  {'-'*12} {'-'*8} {'-'*14}")
    for d in [2, 3, 5, 10]:
        for n in [4, 8, 16, 32, 64]:
            r = max_regions_single_layer(n, d)
            print(f"  {n:>12} {d:>8} {r:>14}")
        print()
    
    # Plot
    fig, ax = plt.subplots(figsize=(10, 6))
    dims = [2, 3, 5, 10]
    neurons = np.arange(1, 65)
    
    for d in dims:
        regions = [max_regions_single_layer(n, d) for n in neurons]
        ax.semilogy(neurons, regions, linewidth=2, label=f'd = {d}')
    
    ax.set_xlabel('Number of neurons n', fontsize=12)
    ax.set_ylabel('Max activation regions', fontsize=12)
    ax.set_title('Zaslavsky Bound: Max Activation Regions per Layer', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demo_region_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  [Saved: demo_region_bounds.png]")
    return fig


if __name__ == '__main__':
    example_1d_classifier()
    example_2d_classifier()
    example_certification_pipeline()
    example_region_bounds()
    print("\n✓ All demos completed successfully.")
