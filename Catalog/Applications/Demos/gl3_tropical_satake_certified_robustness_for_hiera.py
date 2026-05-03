"""
Compositional Robustness for Hierarchical Decision Trees:
Concrete Numerical Demonstrations

This script demonstrates the formally verified theorems from
HierarchicalRobustness.lean with concrete numerical examples and
visualizations.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from dataclasses import dataclass
from typing import List, Tuple, Optional

# ============================================================
# 1. Core Definitions (mirroring Lean formalization)
# ============================================================

def local_margin(go_right: bool, SL: float, SR: float) -> float:
    """Local chosen-vs-other margin at a node.
    Mirrors: def localMargin in Lean."""
    return (SR - SL) if go_right else (SL - SR)


def path_certificate(margins: List[float], K_values: List[float]) -> float:
    """Certified robustness radius = min over nodes of margin/(2*K).
    Mirrors: Finset.inf' (fun v => localMargin v x / (2 * K v))"""
    return min(m / (2 * k) for m, k in zip(margins, K_values) if k > 0)


# ============================================================
# 2. Example: 3-level binary decision tree
# ============================================================

@dataclass
class TreeNode:
    """A node in a binary decision tree."""
    name: str
    go_right: bool  # clean input's branch direction
    K: float        # Lipschitz constant of score difference
    SL_x: float     # left aggregate score at clean input
    SR_x: float     # right aggregate score at clean input

    @property
    def margin(self) -> float:
        return local_margin(self.go_right, self.SL_x, self.SR_x)

    @property
    def normalized_margin(self) -> float:
        return self.margin / (2 * self.K) if self.K > 0 else float('inf')


def demo_three_level_tree():
    """Demonstrate robustness certification on a 3-level decision tree.
    
    Tree structure:
        Root (v0): "Is this a cat or dog-like animal?"
          ├─ Left: v1: "Is it a domestic cat or wild cat?"
          │   ├─ Left: Leaf → "domestic cat"
          │   └─ Right: Leaf → "wild cat"
          └─ Right: v2: "Is it a small dog or large dog?"
              ├─ Left: Leaf → "small dog"
              └─ Right: Leaf → "large dog"
    
    Clean input: a domestic cat image
    Clean path: Root→Left, v1→Left → "domestic cat"
    """
    print("=" * 70)
    print("DEMO 1: Three-Level Hierarchical Decision Tree")
    print("=" * 70)

    # Define the clean path: [Root, v1]
    path = [
        TreeNode("Root (cat vs dog)", go_right=False, K=2.5,
                 SL_x=8.0, SR_x=3.0),   # margin = 8-3 = 5
        TreeNode("v1 (domestic vs wild)", go_right=False, K=1.8,
                 SL_x=6.5, SR_x=2.1),   # margin = 6.5-2.1 = 4.4
    ]

    print("\nClean input classification: domestic cat")
    print("\nPath nodes:")
    for node in path:
        print(f"  {node.name}:")
        print(f"    Branch: {'right' if node.go_right else 'left'}")
        print(f"    SL(x) = {node.SL_x:.1f}, SR(x) = {node.SR_x:.1f}")
        print(f"    Local margin Δ(x) = {node.margin:.2f}")
        print(f"    Lipschitz K = {node.K:.1f}")
        print(f"    Normalized margin Δ/(2K) = {node.normalized_margin:.4f}")

    cert_radius = path_certificate(
        [n.margin for n in path],
        [n.K for n in path]
    )
    print(f"\n  ➤ Certified robustness radius r* = min(Δ/(2K)) = {cert_radius:.4f}")
    print(f"    Bottleneck node: {min(path, key=lambda n: n.normalized_margin).name}")

    # Verify: for perturbation within radius, all margins stay positive
    print("\n  Verification: margins under perturbation")
    test_radii = [0.0, 0.5, 0.9, cert_radius - 0.01, cert_radius, cert_radius + 0.1]
    for r in test_radii:
        min_perturbed = min(n.margin - n.K * r for n in path)
        status = "✓ ROBUST" if min_perturbed > 0 else "✗ NOT CERTIFIED"
        within = "≤ r*" if r <= cert_radius else "> r*"
        print(f"    r = {r:.4f} ({within}): min perturbed margin = {min_perturbed:.4f} {status}")

    return path, cert_radius


def demo_margin_preservation_visualization(path, cert_radius):
    """Visualize how margins decay with perturbation radius."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Margin decay curves
    ax = axes[0]
    r_values = np.linspace(0, cert_radius * 1.5, 200)

    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
    for i, node in enumerate(path):
        # Worst-case perturbed margin: margin - K * r
        perturbed = node.margin - node.K * r_values
        ax.plot(r_values, perturbed, color=colors[i % len(colors)],
                linewidth=2, label=f'{node.name}\n(K={node.K}, Δ={node.margin:.1f})')

    ax.axhline(y=0, color='red', linestyle='--', alpha=0.7, label='Decision boundary')
    ax.axvline(x=cert_radius, color='green', linestyle=':', linewidth=2,
               label=f'r* = {cert_radius:.3f}')
    ax.fill_between(r_values, -2, max(n.margin for n in path) + 1,
                    where=r_values <= cert_radius, alpha=0.1, color='green')
    ax.set_xlabel('Perturbation radius r', fontsize=12)
    ax.set_ylabel('Worst-case margin lower bound', fontsize=12)
    ax.set_title('Margin Decay Along Decision Path', fontsize=14)
    ax.legend(fontsize=9, loc='upper right')
    ax.set_ylim(-2, max(n.margin for n in path) + 1)
    ax.grid(True, alpha=0.3)

    # Right: 2D perturbation ball
    ax = axes[1]
    theta = np.linspace(0, 2 * np.pi, 100)

    # Clean input at origin
    ax.plot(0, 0, 'ko', markersize=10, zorder=5, label='Clean input x')

    # Certified ball
    ax.plot(cert_radius * np.cos(theta), cert_radius * np.sin(theta),
            'g-', linewidth=2, label=f'Certified ball (r*={cert_radius:.3f})')
    ax.fill(cert_radius * np.cos(theta), cert_radius * np.sin(theta),
            alpha=0.15, color='green')

    # Per-node certified balls
    for i, node in enumerate(path):
        r_node = node.normalized_margin
        ax.plot(r_node * np.cos(theta), r_node * np.sin(theta),
                '--', color=colors[i % len(colors)], alpha=0.6,
                label=f'{node.name} (r={r_node:.3f})')

    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.set_xlabel('Perturbation δ₁', fontsize=12)
    ax.set_ylabel('Perturbation δ₂', fontsize=12)
    ax.set_title('Compositional Robustness Certificate', fontsize=14)
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('hierarchical_robustness_demo.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  [Saved: hierarchical_robustness_demo.png]")


# ============================================================
# 3. Comparison: Flat vs Hierarchical certificates
# ============================================================

def demo_flat_vs_hierarchical():
    """Compare flat argmax robustness with hierarchical path robustness."""
    print("\n" + "=" * 70)
    print("DEMO 2: Flat vs Hierarchical Robustness Certificates")
    print("=" * 70)

    # 4-class problem: {cat, dog, bird, fish}
    # Flat argmax scores at clean input
    scores = {'cat': 9.0, 'dog': 5.0, 'bird': 3.0, 'fish': 1.0}
    K_flat = 2.0  # Lipschitz constant for each score

    # Flat certificate: min over non-winner classes of (s_winner - s_j) / (2K)
    winner = 'cat'
    flat_cert = min(
        (scores[winner] - scores[c]) / (2 * 2 * K_flat)  # 2K because both scores move
        for c in scores if c != winner
    )

    print(f"\n  Flat argmax scores: {scores}")
    print(f"  Flat Lipschitz K = {K_flat}")
    print(f"  Flat certified radius = {flat_cert:.4f}")

    # Hierarchical: same classification, structured as tree
    # Root: animal vs non-animal (cat,dog,bird vs fish) - trivial split
    # Level 1: mammal vs bird (cat,dog vs bird)
    # Level 2: cat vs dog
    hier_path = [
        TreeNode("mammal vs bird", go_right=False, K=1.5,
                 SL_x=7.0, SR_x=3.0),   # margin = 4.0
        TreeNode("cat vs dog", go_right=False, K=1.2,
                 SL_x=9.0, SR_x=5.0),   # margin = 4.0
    ]

    hier_cert = path_certificate(
        [n.margin for n in hier_path],
        [n.K for n in hier_path]
    )

    print(f"\n  Hierarchical path: {[n.name for n in hier_path]}")
    for n in hier_path:
        print(f"    {n.name}: margin={n.margin:.1f}, K={n.K}, r_local={n.normalized_margin:.4f}")
    print(f"  Hierarchical certified radius = {hier_cert:.4f}")

    improvement = hier_cert / flat_cert if flat_cert > 0 else float('inf')
    print(f"\n  ➤ Hierarchical improvement factor: {improvement:.2f}x")
    print("    (Hierarchical exploits per-comparison Lipschitz constants)")


# ============================================================
# 4. Additive Budget Variant Demo
# ============================================================

def demo_additive_budget():
    """Demonstrate the summed-loss budget variant."""
    print("\n" + "=" * 70)
    print("DEMO 3: Additive Perturbation Budget Variant")
    print("=" * 70)

    # 5-node path with heterogeneous perturbation budgets
    nodes = [
        ("Feature extraction", 0.5, 3.0),  # (name, K, margin)
        ("Color channel", 0.3, 1.8),
        ("Texture analysis", 0.8, 5.2),
        ("Shape comparison", 0.4, 2.5),
        ("Final discriminator", 0.6, 4.0),
    ]

    print("\n  Node budgets and margins:")
    total_loss_budget = 2.0  # total perturbation budget
    print(f"  Total loss budget L = {total_loss_budget}")
    print()
    all_robust = True
    for name, K, margin in nodes:
        threshold = K * total_loss_budget
        robust = threshold < margin
        all_robust = all_robust and robust
        status = "✓" if robust else "✗"
        print(f"    {name}: K={K}, Δ(x)={margin}, K*L={threshold:.1f} {'<' if robust else '≥'} Δ(x) {status}")

    print(f"\n  ➤ All nodes satisfy K·L < Δ(x): {all_robust}")
    if all_robust:
        print("    By hierarchical_robust_of_summed_losses, classifier is robust")
        print(f"    for ANY perturbation with total loss ≤ {total_loss_budget}")


# ============================================================
# 5. Scaling Analysis
# ============================================================

def demo_scaling():
    """Show how certificate quality scales with tree depth."""
    print("\n" + "=" * 70)
    print("DEMO 4: Certificate Quality vs Tree Depth")
    print("=" * 70)

    fig, ax = plt.subplots(figsize=(10, 6))

    depths = range(1, 21)
    scenarios = [
        ("Uniform margins (Δ=5, K=1)", 5.0, 1.0, '#2196F3'),
        ("High margin (Δ=10, K=1)", 10.0, 1.0, '#4CAF50'),
        ("Tight margins (Δ=2, K=1)", 2.0, 1.0, '#FF5722'),
        ("Low Lipschitz (Δ=5, K=0.5)", 5.0, 0.5, '#9C27B0'),
    ]

    for label, margin, K, color in scenarios:
        certs = [margin / (2 * K)] * len(list(depths))  # min doesn't decrease if uniform
        ax.plot(list(depths), certs, 'o-', color=color, linewidth=2,
                markersize=6, label=label)

    # Non-uniform: decreasing margins
    certs_decreasing = []
    for d in depths:
        margins = [5.0 / (1 + 0.2 * i) for i in range(d)]
        Ks = [1.0] * d
        certs_decreasing.append(path_certificate(margins, Ks))
    ax.plot(list(depths), certs_decreasing, 's--', color='#795548', linewidth=2,
            markersize=6, label='Decreasing margins (Δᵢ=5/(1+0.2i))')

    ax.set_xlabel('Tree depth (path length)', fontsize=12)
    ax.set_ylabel('Certified robustness radius r*', fontsize=12)
    ax.set_title('How Tree Depth Affects Robustness Certificates', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, None)

    plt.tight_layout()
    plt.savefig('certificate_vs_depth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  [Saved: certificate_vs_depth.png]")
    print("\n  Key insight: With uniform margins, the certificate does NOT degrade")
    print("  with depth! The bottleneck is always the weakest node, not the")
    print("  path length. This is the power of compositional certification.")


# ============================================================
# 6. Practical Application: ImageNet-style classifier
# ============================================================

def demo_imagenet_style():
    """Simulate a realistic hierarchical classifier on ImageNet-style categories."""
    print("\n" + "=" * 70)
    print("DEMO 5: Practical Application — ImageNet-Style Hierarchy")
    print("=" * 70)

    # Hierarchy: Animal → Mammal → Canine → Dog breed
    np.random.seed(42)

    # Simulate 100 test images classified as "Golden Retriever"
    n_images = 100
    path_nodes = ["Animal vs Object", "Mammal vs Other Animal",
                  "Canine vs Feline", "Retriever vs Terrier"]

    print(f"\n  Simulating {n_images} clean images classified as 'Golden Retriever'")
    print(f"  Path: {' → '.join(path_nodes)}")

    K_values = [1.2, 0.8, 1.5, 0.6]  # node Lipschitz constants

    cert_radii = []
    bottleneck_counts = {name: 0 for name in path_nodes}

    for _ in range(n_images):
        margins = [np.random.exponential(3.0 + 2.0 * (3 - i)) for i in range(4)]
        normalized = [m / (2 * K) for m, K in zip(margins, K_values)]
        cert_r = min(normalized)
        cert_radii.append(cert_r)

        bottleneck_idx = np.argmin(normalized)
        bottleneck_counts[path_nodes[bottleneck_idx]] += 1

    cert_radii = np.array(cert_radii)

    print(f"\n  Certificate statistics:")
    print(f"    Mean r* = {cert_radii.mean():.4f}")
    print(f"    Median r* = {np.median(cert_radii):.4f}")
    print(f"    Min r* = {cert_radii.min():.4f}")
    print(f"    Max r* = {cert_radii.max():.4f}")
    print(f"\n  Bottleneck distribution:")
    for name, count in bottleneck_counts.items():
        bar = '█' * (count // 2)
        print(f"    {name:30s}: {count:3d}/100 {bar}")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ax = axes[0]
    ax.hist(cert_radii, bins=20, color='#2196F3', alpha=0.7, edgecolor='black')
    ax.axvline(cert_radii.mean(), color='red', linestyle='--',
               label=f'Mean = {cert_radii.mean():.3f}')
    ax.axvline(np.median(cert_radii), color='green', linestyle=':',
               label=f'Median = {np.median(cert_radii):.3f}')
    ax.set_xlabel('Certified robustness radius r*', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Distribution of Path Certificates', fontsize=14)
    ax.legend()
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    names = list(bottleneck_counts.keys())
    counts = list(bottleneck_counts.values())
    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
    ax.barh(names, counts, color=colors)
    ax.set_xlabel('Number of images where this node is bottleneck', fontsize=11)
    ax.set_title('Bottleneck Node Distribution', fontsize=14)
    ax.grid(True, alpha=0.3, axis='x')

    plt.tight_layout()
    plt.savefig('imagenet_certificates.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  [Saved: imagenet_certificates.png]")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  GL3 Tropical Satake: Compositional Hierarchical Robustness Demo   ║")
    print("║  Certified robustness for hierarchical decision tree classifiers    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    path, cert_radius = demo_three_level_tree()
    demo_margin_preservation_visualization(path, cert_radius)
    demo_flat_vs_hierarchical()
    demo_additive_budget()
    demo_scaling()
    demo_imagenet_style()

    print("\n" + "=" * 70)
    print("All demos complete. See generated PNG files for visualizations.")
    print("=" * 70)
