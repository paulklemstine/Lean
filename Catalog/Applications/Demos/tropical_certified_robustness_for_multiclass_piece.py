#!/usr/bin/env python3
"""
Tropical Certified Robustness for Hierarchical Max-Aggregation Trees
=====================================================================

This demo illustrates the formally verified theorems with concrete numerical
examples, showing how hierarchical max-aggregation trees propagate Lipschitz
constants and how subtree logit-gap certificates yield robustness radii.

The Lean formalization proves these guarantees for arbitrary PseudoMetricSpaces.
Here we specialize to ℝ^n with L∞ norm for concreteness.
"""

import numpy as np
import matplotlib.pyplot as plt
from dataclasses import dataclass
from typing import Callable, Union, List, Optional
import os

# ─── AggTree data structure ───────────────────────────────────────────────────

@dataclass
class Leaf:
    """A leaf node: score function f : κ → ℝⁿ → ℝ, with Lipschitz constant L."""
    f: Callable[[int, np.ndarray], float]  # f(class_idx, x) → score
    L: float  # Lipschitz constant
    name: str = ""

@dataclass
class Bin:
    """A binary internal node: takes pointwise max of two subtrees."""
    left: Union['Leaf', 'Bin']
    right: Union['Leaf', 'Bin']

AggTree = Union[Leaf, Bin]

def eval_tree(T: AggTree, x: np.ndarray, i: int) -> float:
    """Evaluate T at input x for class i."""
    if isinstance(T, Leaf):
        return T.f(i, x)
    else:
        return max(eval_tree(T.left, x, i), eval_tree(T.right, x, i))

def lip(T: AggTree) -> float:
    """Recursive Lipschitz bound (max across leaves)."""
    if isinstance(T, Leaf):
        return T.L
    else:
        return max(lip(T.left), lip(T.right))

def gap(T: AggTree, x: np.ndarray, i: int, j: int) -> float:
    """Logit gap: score(i) - score(j)."""
    return eval_tree(T, x, i) - eval_tree(T, x, j)

def cert_gap(T: AggTree, x: np.ndarray, i: int, j: int) -> float:
    """Recursive certified gap (min over subtree gaps)."""
    if isinstance(T, Leaf):
        return T.f(i, x) - T.f(j, x)
    else:
        return min(cert_gap(T.left, x, i, j), cert_gap(T.right, x, i, j))

def cert_radius(T: AggTree, x: np.ndarray, winner: int, classes: List[int]) -> float:
    """Certified robustness radius: min over competitors of cert_gap / (2 * lip)."""
    L = lip(T)
    if L <= 0:
        return float('inf')
    competitors = [j for j in classes if j != winner]
    if not competitors:
        return float('inf')
    return min(cert_gap(T, x, winner, j) / (2 * L) for j in competitors)

def is_strict_winner(T: AggTree, x: np.ndarray, winner: int, classes: List[int]) -> bool:
    """Check if winner beats all other classes."""
    return all(eval_tree(T, x, winner) > eval_tree(T, x, j)
               for j in classes if j != winner)


# ─── Demo 1: Basic tree with linear score functions ──────────────────────────

def demo_basic():
    """
    Demo 1: A simple hierarchical max-aggregation tree with 3 classes and 2D input.
    
    Tree structure:
        root (max)
        ├── left (max)
        │   ├── leaf₁: f₁(i, x) = wᵢ · x + bᵢ  (L=2.0)
        │   └── leaf₂: f₂(i, x) = vᵢ · x + cᵢ  (L=1.5)
        └── right:
            └── leaf₃: f₃(i, x) = uᵢ · x + dᵢ  (L=1.0)
    """
    print("=" * 70)
    print("DEMO 1: Basic Hierarchical Max-Aggregation Tree")
    print("=" * 70)
    
    # Define 3-class score functions on ℝ²
    W1 = np.array([[2.0, 0.5], [-0.5, 1.0], [0.3, -0.8]])  # class weights for leaf 1
    b1 = np.array([1.0, 0.5, -0.3])
    
    W2 = np.array([[0.8, 1.2], [1.0, -0.3], [-0.5, 0.7]])  # class weights for leaf 2
    b2 = np.array([0.2, 0.8, 0.1])
    
    W3 = np.array([[0.5, 0.5], [0.3, 0.9], [-0.2, 0.4]])  # class weights for leaf 3
    b3 = np.array([0.3, -0.1, 0.6])
    
    def make_linear(W, b, L):
        def f(i, x):
            return float(W[i] @ x + b[i])
        return Leaf(f=f, L=L, name=f"linear(L={L})")
    
    leaf1 = make_linear(W1, b1, L=2.5)  # ||W1[i]||_1 ≤ 2.5
    leaf2 = make_linear(W2, b2, L=2.0)
    leaf3 = make_linear(W3, b3, L=1.4)
    
    left_node = Bin(leaf1, leaf2)
    tree = Bin(left_node, leaf3)
    
    classes = [0, 1, 2]
    x0 = np.array([1.0, 0.5])
    
    print(f"\nInput x₀ = {x0}")
    print(f"Tree Lipschitz constant: L = {lip(tree):.2f}")
    print(f"\nClass scores at x₀:")
    for i in classes:
        score = eval_tree(tree, x0, i)
        print(f"  class {i}: score = {score:.4f}")
    
    winner = max(classes, key=lambda i: eval_tree(tree, x0, i))
    print(f"\nPredicted class: {winner}")
    
    print(f"\nLogit gaps (winner vs. competitors):")
    for j in classes:
        if j != winner:
            g = gap(tree, x0, winner, j)
            cg = cert_gap(tree, x0, winner, j)
            print(f"  gap({winner},{j}) = {g:.4f},  certGap({winner},{j}) = {cg:.4f}")
    
    r = cert_radius(tree, x0, winner, classes)
    print(f"\nCertified robustness radius: r = {r:.4f}")
    print(f"  → Any perturbation x' with ||x' - x₀||∞ < {r:.4f} preserves class {winner}")
    
    # Verify by sampling perturbations
    print(f"\nVerification: sampling 10000 random perturbations within radius...")
    n_samples = 10000
    n_stable = 0
    for _ in range(n_samples):
        delta = np.random.uniform(-r * 0.99, r * 0.99, size=2)
        x_pert = x0 + delta
        if is_strict_winner(tree, x_pert, winner, classes):
            n_stable += 1
    print(f"  Stable predictions: {n_stable}/{n_samples} ({100*n_stable/n_samples:.1f}%)")
    
    return tree, x0, winner, classes, r


# ─── Demo 2: Visualizing the robustness certificate ─────────────────────────

def demo_visualization(tree, x0, winner, classes, r):
    """
    Demo 2: Visualize the certified robustness region and decision boundaries.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Robustness Certificate Visualization")
    print("=" * 70)
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
    
    # Panel 1: Decision regions with certified ball
    ax = axes[0]
    grid_range = 3.0
    resolution = 200
    xx, yy = np.meshgrid(np.linspace(x0[0]-grid_range, x0[0]+grid_range, resolution),
                          np.linspace(x0[1]-grid_range, x0[1]+grid_range, resolution))
    
    predictions = np.zeros_like(xx, dtype=int)
    for ii in range(resolution):
        for jj in range(resolution):
            x = np.array([xx[ii, jj], yy[ii, jj]])
            scores = [eval_tree(tree, x, i) for i in classes]
            predictions[ii, jj] = np.argmax(scores)
    
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1']
    cmap = plt.matplotlib.colors.ListedColormap(colors)
    ax.contourf(xx, yy, predictions, levels=[-0.5, 0.5, 1.5, 2.5], colors=colors, alpha=0.3)
    ax.contour(xx, yy, predictions, levels=[0.5, 1.5], colors='gray', linewidths=0.5)
    
    # Draw certified ball (L∞)
    rect = plt.Rectangle((x0[0]-r, x0[1]-r), 2*r, 2*r,
                          linewidth=2, edgecolor='black', facecolor='gold', alpha=0.3,
                          label=f'Certified region (r={r:.3f})')
    ax.add_patch(rect)
    ax.plot(*x0, 'k*', markersize=15, label=f'x₀ (class {winner})')
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_title('Decision Regions & Certified Ball')
    ax.legend(fontsize=8)
    ax.set_aspect('equal')
    
    # Panel 2: Score profiles along a perturbation direction
    ax = axes[1]
    direction = np.array([1.0, 0.0])  # perturb along x₁
    epsilons = np.linspace(-2*r, 2*r, 300)
    
    for i in classes:
        scores = [eval_tree(tree, x0 + eps * direction, i) for eps in epsilons]
        ax.plot(epsilons, scores, label=f'Class {i}', linewidth=2)
    
    ax.axvline(-r, color='black', linestyle='--', alpha=0.5, label='±r boundary')
    ax.axvline(r, color='black', linestyle='--', alpha=0.5)
    ax.axvspan(-r, r, alpha=0.1, color='gold')
    ax.set_xlabel('Perturbation ε (along x₁)')
    ax.set_ylabel('Score')
    ax.set_title('Score Profiles Under Perturbation')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Gap degradation
    ax = axes[2]
    competitors = [j for j in classes if j != winner]
    
    for j in competitors:
        gaps = [gap(tree, x0 + eps * direction, winner, j) for eps in epsilons]
        ax.plot(epsilons, gaps, label=f'gap({winner},{j})', linewidth=2)
        
        # Theoretical lower bound: certGap - 2*L*|eps|
        L = lip(tree)
        cg = cert_gap(tree, x0, winner, j)
        bounds = [cg - 2 * L * abs(eps) for eps in epsilons]
        ax.plot(epsilons, bounds, '--', alpha=0.5, label=f'bound({winner},{j})')
    
    ax.axhline(0, color='red', linewidth=1, alpha=0.7)
    ax.axvline(-r, color='black', linestyle='--', alpha=0.5)
    ax.axvline(r, color='black', linestyle='--', alpha=0.5)
    ax.axvspan(-r, r, alpha=0.1, color='gold')
    ax.set_xlabel('Perturbation ε (along x₁)')
    ax.set_ylabel('Gap')
    ax.set_title('Gap Degradation & Certified Bounds')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'robustness_certificate.png'), dpi=150)
    plt.close()
    print("  → Saved robustness_certificate.png")


# ─── Demo 3: Deep tree with many layers ─────────────────────────────────────

def demo_deep_tree():
    """
    Demo 3: Deep hierarchical tree showing Lipschitz propagation.
    
    Builds a balanced binary tree of depth D, showing that the global
    Lipschitz constant equals the maximum leaf constant (not the sum!).
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Deep Tree Lipschitz Propagation")
    print("=" * 70)
    
    n_classes = 4
    input_dim = 5
    
    def random_leaf(L_max=2.0):
        """Create a random linear leaf with bounded Lipschitz constant."""
        W = np.random.randn(n_classes, input_dim)
        # Scale so L1 norm ≤ L_max
        for i in range(n_classes):
            norm = np.sum(np.abs(W[i]))
            if norm > 0:
                W[i] = W[i] / norm * np.random.uniform(0.5, L_max)
        b = np.random.randn(n_classes) * 0.5
        L = max(np.sum(np.abs(W[i])) for i in range(n_classes))
        
        def f(cls, x, W=W, b=b):
            return float(W[cls] @ x + b[cls])
        return Leaf(f=f, L=L)
    
    def build_balanced_tree(depth):
        if depth == 0:
            return random_leaf()
        else:
            return Bin(build_balanced_tree(depth - 1),
                       build_balanced_tree(depth - 1))
    
    np.random.seed(42)
    
    print(f"\n{'Depth':<8} {'#Leaves':<10} {'Lip(T)':<12} {'Max leaf L':<12} {'Match?'}")
    print("-" * 55)
    
    for depth in range(1, 7):
        tree = build_balanced_tree(depth)
        n_leaves = 2 ** depth
        L_tree = lip(tree)
        
        # Collect all leaf Lipschitz constants
        def collect_leaf_lips(T):
            if isinstance(T, Leaf):
                return [T.L]
            return collect_leaf_lips(T.left) + collect_leaf_lips(T.right)
        
        leaf_lips = collect_leaf_lips(tree)
        max_leaf_L = max(leaf_lips)
        
        match = "✓" if abs(L_tree - max_leaf_L) < 1e-10 else "✗"
        print(f"{depth:<8} {n_leaves:<10} {L_tree:<12.6f} {max_leaf_L:<12.6f} {match}")
    
    print("\nKey insight: lip(T) = max over leaves, NOT sum!")
    print("This is because max(a,b) is 1-Lipschitz in each argument,")
    print("so composing max preserves the maximum Lipschitz constant.")


# ─── Demo 4: Comparing flat vs hierarchical certificates ────────────────────

def demo_comparison():
    """
    Demo 4: Compare certified radii of flat vs. hierarchical aggregation.
    
    Shows that deeper trees can sometimes give tighter per-subtree gaps,
    leading to more informative certificates.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Flat vs. Hierarchical Certificates")
    print("=" * 70)
    
    # 2 classes, 2D input
    classes = [0, 1]
    
    # Four leaves with different specializations
    def make_leaf(w0, b0, w1, b1, L):
        def f(i, x):
            if i == 0:
                return float(w0 @ x + b0)
            else:
                return float(w1 @ x + b1)
        return Leaf(f=f, L=L)
    
    leaves = [
        make_leaf(np.array([1.0, 0.5]), 2.0,
                  np.array([0.3, 0.2]), 0.5, 1.5),
        make_leaf(np.array([0.5, 1.0]), 1.5,
                  np.array([0.2, 0.8]), 0.3, 1.5),
        make_leaf(np.array([0.8, 0.3]), 1.0,
                  np.array([0.1, 0.4]), 0.8, 1.1),
        make_leaf(np.array([0.3, 0.7]), 1.8,
                  np.array([0.5, 0.1]), 0.2, 1.0),
    ]
    
    x0 = np.array([0.5, 0.5])
    
    # Flat tree: max of all 4
    flat = Bin(Bin(leaves[0], leaves[1]), Bin(leaves[2], leaves[3]))
    
    # Hierarchical: grouped differently
    hier = Bin(Bin(leaves[0], leaves[2]), Bin(leaves[1], leaves[3]))
    
    print(f"\nInput x₀ = {x0}")
    print(f"\nFlat grouping: ((leaf0, leaf1), (leaf2, leaf3))")
    print(f"  Lip = {lip(flat):.4f}")
    for j in classes:
        if j != 0:
            print(f"  certGap(0,{j}) = {cert_gap(flat, x0, 0, j):.4f}")
            print(f"  gap(0,{j})     = {gap(flat, x0, 0, j):.4f}")
    r_flat = cert_radius(flat, x0, 0, classes)
    print(f"  certRadius = {r_flat:.4f}")
    
    print(f"\nHierarchical grouping: ((leaf0, leaf2), (leaf1, leaf3))")
    print(f"  Lip = {lip(hier):.4f}")
    for j in classes:
        if j != 0:
            print(f"  certGap(0,{j}) = {cert_gap(hier, x0, 0, j):.4f}")
            print(f"  gap(0,{j})     = {gap(hier, x0, 0, j):.4f}")
    r_hier = cert_radius(hier, x0, 0, classes)
    print(f"  certRadius = {r_hier:.4f}")
    
    print(f"\nBoth groupings give the same eval (max is associative/commutative):")
    for i in classes:
        sf = eval_tree(flat, x0, i)
        sh = eval_tree(hier, x0, i)
        print(f"  class {i}: flat={sf:.4f}, hier={sh:.4f}, match={abs(sf-sh)<1e-10}")
    
    print(f"\nBut certificates may differ due to subtree gap structure!")
    print(f"  certRadius(flat)  = {r_flat:.4f}")
    print(f"  certRadius(hier)  = {r_hier:.4f}")


# ─── Demo 5: Application to ensemble model robustness ────────────────────────

def demo_ensemble():
    """
    Demo 5: Certifying robustness of a max-ensemble of classifiers.
    
    This models a practical scenario: an ensemble of N classifiers where the
    final prediction uses the maximum score across all models for each class.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Ensemble Model Robustness Certification")
    print("=" * 70)
    
    np.random.seed(123)
    n_models = 8
    n_classes = 5
    input_dim = 10
    
    print(f"\nEnsemble: {n_models} models, {n_classes} classes, {input_dim}D input")
    
    # Create random linear classifiers
    models = []
    for m in range(n_models):
        W = np.random.randn(n_classes, input_dim) * 0.5
        b = np.random.randn(n_classes) * 0.2
        L = max(np.sum(np.abs(W[i])) for i in range(n_classes))
        
        def f(cls, x, W=W, b=b):
            return float(W[cls] @ x + b[cls])
        
        models.append(Leaf(f=f, L=L, name=f"model_{m}"))
    
    # Build balanced binary tree over models
    def build_tree(leaves):
        if len(leaves) == 1:
            return leaves[0]
        mid = len(leaves) // 2
        return Bin(build_tree(leaves[:mid]), build_tree(leaves[mid:]))
    
    tree = build_tree(models)
    classes = list(range(n_classes))
    
    # Test on multiple inputs
    print(f"\nGlobal Lipschitz constant: L = {lip(tree):.4f}")
    print(f"\nPer-model Lipschitz constants:")
    for m, model in enumerate(models):
        print(f"  model_{m}: L = {model.L:.4f}")
    
    print(f"\n{'Input':<8} {'Winner':<8} {'certRadius':<12} {'Min gap':<12} {'Min certGap':<12}")
    print("-" * 55)
    
    for trial in range(10):
        x = np.random.randn(input_dim) * 0.5
        scores = [eval_tree(tree, x, i) for i in classes]
        winner = np.argmax(scores)
        
        min_gap = min(gap(tree, x, winner, j) for j in classes if j != winner)
        min_cg = min(cert_gap(tree, x, winner, j) for j in classes if j != winner)
        r = cert_radius(tree, x, winner, classes)
        
        print(f"x_{trial:<5} {winner:<8} {r:<12.6f} {min_gap:<12.6f} {min_cg:<12.6f}")


# ─── Demo 6: Visualizing certificate tightness across space ─────────────────

def demo_radius_heatmap(tree, classes):
    """
    Demo 6: Heatmap of certified robustness radius across input space.
    """
    print("\n" + "=" * 70)
    print("DEMO 6: Robustness Radius Heatmap")
    print("=" * 70)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))
    
    resolution = 150
    x_range = np.linspace(-2, 3, resolution)
    y_range = np.linspace(-2, 3, resolution)
    
    radius_map = np.zeros((resolution, resolution))
    winner_map = np.zeros((resolution, resolution), dtype=int)
    
    for ii, x1 in enumerate(x_range):
        for jj, x2 in enumerate(y_range):
            x = np.array([x1, x2])
            scores = [eval_tree(tree, x, i) for i in classes]
            winner = np.argmax(scores)
            winner_map[jj, ii] = winner
            
            competitors = [j for j in classes if j != winner]
            if competitors:
                r = cert_radius(tree, x, winner, classes)
                radius_map[jj, ii] = max(0, r)
            else:
                radius_map[jj, ii] = 1.0
    
    # Panel 1: Decision regions
    ax = axes[0]
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1']
    cmap = plt.matplotlib.colors.ListedColormap(colors[:len(classes)])
    ax.contourf(x_range, y_range, winner_map, levels=np.arange(-0.5, len(classes)), 
                colors=colors[:len(classes)], alpha=0.4)
    ax.contour(x_range, y_range, winner_map, levels=np.arange(0.5, len(classes)-0.5),
               colors='gray', linewidths=1)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_title('Decision Regions')
    ax.set_aspect('equal')
    
    # Panel 2: Robustness radius heatmap
    ax = axes[1]
    im = ax.imshow(radius_map, extent=[-2, 3, -2, 3], origin='lower',
                    cmap='viridis', aspect='equal')
    ax.contour(x_range, y_range, winner_map, levels=np.arange(0.5, len(classes)-0.5),
               colors='white', linewidths=1, linestyles='--')
    plt.colorbar(im, ax=ax, label='Certified radius')
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_title('Certified Robustness Radius')
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'radius_heatmap.png'), dpi=150)
    plt.close()
    print("  → Saved radius_heatmap.png")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Certified Robustness for Max-Aggregation Trees           ║")
    print("║  Companion demos for the Lean 4 formal verification               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    tree, x0, winner, classes, r = demo_basic()
    demo_visualization(tree, x0, winner, classes, r)
    demo_deep_tree()
    demo_comparison()
    demo_ensemble()
    demo_radius_heatmap(tree, classes)
    
    print("\n" + "=" * 70)
    print("SUMMARY OF FORMALLY VERIFIED THEOREMS")
    print("=" * 70)
    print("""
    1. eval_lip: Max-aggregation preserves Lipschitz constants.
       If each leaf is L_i-Lipschitz, the tree is (max_i L_i)-Lipschitz.

    2. certGap_le_gap: Subtree certificate monotonicity.
       min over subtree gaps ≤ root gap.

    3. gap_perturb_lower_bound: Gap degradation bound.
       gap(T, x', i, j) ≥ gap(T, x, i, j) - 2·L·dist(x, x').

    4. argmax_stable: Classification stability.
       If certGap > 2·L·dist for all competitors, prediction is stable.

    5. certRadius_spec: Robustness radius certificate.
       Within radius min_j certGap(y,j)/(2L), the winner is preserved.

    All theorems are machine-verified in Lean 4 with Mathlib,
    using only standard axioms (propext, Classical.choice, Quot.sound).
    """)
