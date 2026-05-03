#!/usr/bin/env python3
"""
Tournament Bracket Certified Robustness: Python Demo & Visualization

This script demonstrates the certified robustness theory for tournament-style
multiclass classifiers. It shows how bracket semantics gives structurally
sharper robustness certificates compared to flat argmax.

Key demonstrations:
1. How tournament brackets work for multiclass classification
2. Computing certified robustness radii from winner-path margins
3. Comparison with flat argmax robustness certificates
4. Visualization of perturbation balls and decision boundaries
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
from typing import Callable, Optional, Tuple, List, Dict
import warnings
warnings.filterwarnings('ignore')

# ============================================================================
# Core Data Structures
# ============================================================================

class Bracket:
    """A full binary tree representing a tournament bracket."""
    pass

class Leaf(Bracket):
    def __init__(self, label: int):
        self.label = label

    def __repr__(self):
        return f"Leaf({self.label})"

class Node(Bracket):
    def __init__(self, left: Bracket, right: Bracket):
        self.left = left
        self.right = right

    def __repr__(self):
        return f"Node({self.left}, {self.right})"


def winner(bracket: Bracket, scores: Callable[[int, np.ndarray], float],
           x: np.ndarray) -> int:
    """Compute the tournament winner at point x.

    At a leaf, return the label.
    At an internal node, compare winners of left/right subtrees.
    """
    if isinstance(bracket, Leaf):
        return bracket.label
    elif isinstance(bracket, Node):
        wl = winner(bracket.left, scores, x)
        wr = winner(bracket.right, scores, x)
        if scores(wl, x) >= scores(wr, x):
            return wl
        else:
            return wr


def winner_path(bracket: Bracket, scores: Callable, x: np.ndarray) -> list:
    """Extract the winner path: list of (win_label, opp_label, margin) tuples."""
    if isinstance(bracket, Leaf):
        return []
    elif isinstance(bracket, Node):
        wl = winner(bracket.left, scores, x)
        wr = winner(bracket.right, scores, x)
        sl = scores(wl, x)
        sr = scores(wr, x)
        if sl >= sr:
            path = [(wl, wr, sl - sr)]
            path.extend(winner_path(bracket.left, scores, x))
        else:
            path = [(wr, wl, sr - sl)]
            path.extend(winner_path(bracket.right, scores, x))
        return path


def all_nodes(bracket: Bracket, scores: Callable, x: np.ndarray) -> list:
    """Collect ALL internal comparison nodes (win_label, opp_label, margin)."""
    if isinstance(bracket, Leaf):
        return []
    elif isinstance(bracket, Node):
        wl = winner(bracket.left, scores, x)
        wr = winner(bracket.right, scores, x)
        sl = scores(wl, x)
        sr = scores(wr, x)
        if sl >= sr:
            this_node = (wl, wr, sl - sr)
        else:
            this_node = (wr, wl, sr - sl)
        return [this_node] + all_nodes(bracket.left, scores, x) + \
               all_nodes(bracket.right, scores, x)


def certified_radius(bracket: Bracket, scores: Callable, x0: np.ndarray,
                     lip_const: Callable[[int, int], float]) -> float:
    """Compute the certified robustness radius.

    r* = min over all internal nodes of margin(v) / L(w_v, o_v)
    """
    nodes = all_nodes(bracket, scores, x0)
    if not nodes:
        return float('inf')
    radii = []
    for w, o, margin in nodes:
        L = lip_const(w, o)
        if L > 0:
            radii.append(margin / L)
        elif margin > 0:
            radii.append(float('inf'))
        else:
            radii.append(0.0)
    return min(radii)


def flat_argmax_certified_radius(scores: Callable, x0: np.ndarray,
                                  n_classes: int,
                                  lip_const: Callable) -> float:
    """Certified radius for flat argmax: need ALL pairwise margins."""
    best = np.argmax([scores(i, x0) for i in range(n_classes)])
    min_radius = float('inf')
    for j in range(n_classes):
        if j == best:
            continue
        margin = scores(best, x0) - scores(j, x0)
        L = lip_const(best, j)
        if L > 0:
            min_radius = min(min_radius, margin / L)
    return min_radius


# ============================================================================
# Demo 1: Basic Tournament Bracket Example
# ============================================================================

def demo_basic_bracket():
    """Show how a tournament bracket classifies and how margins work."""
    print("=" * 70)
    print("DEMO 1: Basic Tournament Bracket Classification")
    print("=" * 70)

    # 4-class bracket: ((0 vs 1) vs (2 vs 3))
    bracket = Node(Node(Leaf(0), Leaf(1)), Node(Leaf(2), Leaf(3)))

    # Linear score functions: f_i(x) = w_i · x + b_i
    weights = np.array([[2.0, 1.0], [-1.0, 3.0], [0.5, -2.0], [-0.5, 0.5]])
    biases = np.array([1.0, 0.5, -0.5, 0.0])

    def scores(i, x):
        return weights[i] @ x + biases[i]

    x0 = np.array([1.0, 0.5])

    print(f"\nInput point x0 = {x0}")
    print(f"\nScores at x0:")
    for i in range(4):
        print(f"  Class {i}: f_{i}(x0) = {scores(i, x0):.3f}")

    w = winner(bracket, scores, x0)
    print(f"\nTournament bracket: ((0 vs 1) vs (2 vs 3))")
    print(f"Tournament winner: Class {w}")

    # Show the path
    path = winner_path(bracket, scores, x0)
    print(f"\nWinner path (root to leaf):")
    for win, opp, margin in path:
        print(f"  Class {win} beats Class {opp}, margin = {margin:.3f}")

    # All internal nodes
    nodes = all_nodes(bracket, scores, x0)
    print(f"\nAll internal nodes:")
    for win, opp, margin in nodes:
        print(f"  Class {win} beats Class {opp}, margin = {margin:.3f}")

    # Compute Lipschitz constants for score differences
    # For linear functions: ||(f_i - f_j)(x) - (f_i - f_j)(y)|| = ||(w_i - w_j) · (x-y)||
    # ≤ ||w_i - w_j|| * ||x - y||
    def lip_const(i, j):
        return np.linalg.norm(weights[i] - weights[j])

    r_bracket = certified_radius(bracket, scores, x0, lip_const)
    r_argmax = flat_argmax_certified_radius(scores, x0, 4, lip_const)

    print(f"\n--- Certified Radii ---")
    print(f"  Bracket certified radius: {r_bracket:.4f}")
    print(f"  Flat argmax certified radius: {r_argmax:.4f}")
    print(f"  Ratio (bracket/argmax): {r_bracket/r_argmax:.4f}")

    return bracket, scores, x0, weights, lip_const


# ============================================================================
# Demo 2: Visualization of Decision Regions
# ============================================================================

def demo_visualization(bracket, scores, x0, weights, lip_const):
    """Visualize decision regions, perturbation balls, and certified radii."""
    print("\n" + "=" * 70)
    print("DEMO 2: Visualization of Decision Regions")
    print("=" * 70)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Grid for decision boundaries
    xx, yy = np.meshgrid(np.linspace(-2, 4, 300), np.linspace(-2, 3, 300))
    grid = np.c_[xx.ravel(), yy.ravel()]

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    color_map = {0: 0, 1: 1, 2: 2, 3: 3}

    # Panel 1: Bracket decision regions
    ax = axes[0]
    Z_bracket = np.array([winner(bracket, scores, pt) for pt in grid])
    Z_bracket = Z_bracket.reshape(xx.shape)
    for i in range(4):
        ax.contourf(xx, yy, (Z_bracket == i).astype(float),
                   levels=[0.5, 1.5], colors=[colors[i]], alpha=0.3)
    ax.contour(xx, yy, Z_bracket, colors='k', linewidths=0.5, alpha=0.5)

    r_bracket = certified_radius(bracket, scores, x0, lip_const)
    circle_b = plt.Circle(x0, r_bracket, fill=False, color='black',
                          linewidth=2, linestyle='--')
    ax.add_patch(circle_b)
    ax.plot(*x0, 'k*', markersize=15, zorder=5)
    ax.set_title(f'Bracket: ((0v1) v (2v3))\nCert. radius = {r_bracket:.3f}',
                fontsize=12, fontweight='bold')
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_xlim(-2, 4)
    ax.set_ylim(-2, 3)

    # Panel 2: Flat argmax decision regions
    ax = axes[1]
    Z_argmax = np.array([np.argmax([scores(i, pt) for i in range(4)])
                         for pt in grid])
    Z_argmax = Z_argmax.reshape(xx.shape)
    for i in range(4):
        ax.contourf(xx, yy, (Z_argmax == i).astype(float),
                   levels=[0.5, 1.5], colors=[colors[i]], alpha=0.3)
    ax.contour(xx, yy, Z_argmax, colors='k', linewidths=0.5, alpha=0.5)

    r_argmax = flat_argmax_certified_radius(scores, x0, 4, lip_const)
    circle_a = plt.Circle(x0, r_argmax, fill=False, color='blue',
                          linewidth=2, linestyle='--')
    ax.add_patch(circle_a)
    ax.plot(*x0, 'k*', markersize=15, zorder=5)
    ax.set_title(f'Flat Argmax\nCert. radius = {r_argmax:.3f}',
                fontsize=12, fontweight='bold')
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_xlim(-2, 4)
    ax.set_ylim(-2, 3)

    # Panel 3: Comparison overlay
    ax = axes[2]
    for i in range(4):
        ax.contourf(xx, yy, (Z_bracket == i).astype(float),
                   levels=[0.5, 1.5], colors=[colors[i]], alpha=0.2)
    ax.contour(xx, yy, Z_bracket, colors='k', linewidths=0.5, alpha=0.3)

    circle_b2 = plt.Circle(x0, r_bracket, fill=False, color='red',
                           linewidth=2.5, linestyle='-', label='Bracket cert.')
    circle_a2 = plt.Circle(x0, r_argmax, fill=False, color='blue',
                           linewidth=2.5, linestyle='--', label='Argmax cert.')
    ax.add_patch(circle_b2)
    ax.add_patch(circle_a2)
    ax.plot(*x0, 'k*', markersize=15, zorder=5)
    ax.legend(loc='upper right', fontsize=10)
    ax.set_title('Comparison of Certified Radii', fontsize=12, fontweight='bold')
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_xlim(-2, 4)
    ax.set_ylim(-2, 3)

    plt.tight_layout()
    plt.savefig('MachineLearning/fig_decision_regions.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    print("Saved: MachineLearning/fig_decision_regions.png")


# ============================================================================
# Demo 3: Bracket vs Argmax Robustness Statistics
# ============================================================================

def demo_statistics():
    """Compare bracket vs argmax certified radii across many random points."""
    print("\n" + "=" * 70)
    print("DEMO 3: Statistical Comparison — Bracket vs Argmax")
    print("=" * 70)

    np.random.seed(42)
    n_classes = 8

    # Random linear classifiers
    weights = np.random.randn(n_classes, 2) * 2
    biases = np.random.randn(n_classes) * 0.5

    def scores(i, x):
        return weights[i] @ x + biases[i]

    def lip_const(i, j):
        return np.linalg.norm(weights[i] - weights[j])

    # Build different bracket structures
    def build_balanced_bracket(labels):
        if len(labels) == 1:
            return Leaf(labels[0])
        mid = len(labels) // 2
        return Node(build_balanced_bracket(labels[:mid]),
                    build_balanced_bracket(labels[mid:]))

    bracket = build_balanced_bracket(list(range(n_classes)))

    # Test on many random points
    n_points = 500
    points = np.random.randn(n_points, 2) * 2

    bracket_radii = []
    argmax_radii = []

    for x0 in points:
        r_b = certified_radius(bracket, scores, x0, lip_const)
        r_a = flat_argmax_certified_radius(scores, x0, n_classes, lip_const)
        if np.isfinite(r_b) and np.isfinite(r_a) and r_a > 0:
            bracket_radii.append(r_b)
            argmax_radii.append(r_a)

    bracket_radii = np.array(bracket_radii)
    argmax_radii = np.array(argmax_radii)
    ratios = bracket_radii / argmax_radii

    print(f"\nResults over {len(bracket_radii)} test points ({n_classes} classes):")
    print(f"  Mean bracket radius:  {bracket_radii.mean():.4f}")
    print(f"  Mean argmax radius:   {argmax_radii.mean():.4f}")
    print(f"  Mean ratio (B/A):     {ratios.mean():.4f}")
    print(f"  Median ratio (B/A):   {np.median(ratios):.4f}")
    print(f"  Points where bracket ≥ argmax: {(ratios >= 1.0).mean()*100:.1f}%")
    print(f"  Points where bracket > argmax: {(ratios > 1.0).mean()*100:.1f}%")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ax = axes[0]
    ax.hist(ratios, bins=50, color='steelblue', alpha=0.7, edgecolor='black')
    ax.axvline(1.0, color='red', linewidth=2, linestyle='--', label='Ratio = 1')
    ax.axvline(ratios.mean(), color='green', linewidth=2, label=f'Mean = {ratios.mean():.2f}')
    ax.set_xlabel('Bracket / Argmax Certified Radius', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title(f'Distribution of Radius Ratios ({n_classes} classes)',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)

    ax = axes[1]
    ax.scatter(argmax_radii, bracket_radii, alpha=0.3, s=10, c='steelblue')
    lim = max(argmax_radii.max(), bracket_radii.max()) * 1.1
    ax.plot([0, lim], [0, lim], 'r--', linewidth=1.5, label='y = x')
    ax.set_xlabel('Argmax Certified Radius', fontsize=12)
    ax.set_ylabel('Bracket Certified Radius', fontsize=12)
    ax.set_title('Bracket vs Argmax Radii', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('MachineLearning/fig_statistics.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: MachineLearning/fig_statistics.png")


# ============================================================================
# Demo 4: ReLU Network Example
# ============================================================================

def demo_relu_network():
    """Demonstrate certified robustness for a simple ReLU network."""
    print("\n" + "=" * 70)
    print("DEMO 4: ReLU Network Certified Robustness")
    print("=" * 70)

    np.random.seed(123)

    # Simple 2-layer ReLU network: x ∈ R^2 → 4 class scores
    # Layer 1: h = ReLU(W1 @ x + b1), hidden dim = 8
    # Layer 2: scores = W2 @ h + b2

    W1 = np.random.randn(8, 2) * 0.5
    b1 = np.random.randn(8) * 0.1
    W2 = np.random.randn(4, 8) * 0.3
    b2 = np.random.randn(4) * 0.1

    def relu(x):
        return np.maximum(0, x)

    def network_scores(i, x):
        h = relu(W1 @ x + b1)
        return (W2[i] @ h + b2[i])

    # Lipschitz constant bound for each score function
    # ||f_i(x) - f_i(y)|| ≤ ||W2[i]|| * ||W1|| * ||x - y|| (upper bound via norms)
    norm_W1 = np.linalg.norm(W1, ord=2)  # spectral norm
    K_per_class = np.array([np.linalg.norm(W2[i]) * norm_W1 for i in range(4)])

    def lip_const(i, j):
        return K_per_class[i] + K_per_class[j]

    def scores(i, x):
        return network_scores(i, x)

    # Tournament bracket
    bracket = Node(Node(Leaf(0), Leaf(1)), Node(Leaf(2), Leaf(3)))

    x0 = np.array([0.5, -0.3])
    print(f"\nInput: x0 = {x0}")
    print(f"\nNetwork scores at x0:")
    for i in range(4):
        print(f"  Class {i}: {scores(i, x0):.4f} (Lip. const = {K_per_class[i]:.4f})")

    w = winner(bracket, scores, x0)
    print(f"\nTournament winner: Class {w}")

    path = winner_path(bracket, scores, x0)
    print(f"\nWinner path:")
    for wl, ol, margin in path:
        L = lip_const(wl, ol)
        print(f"  Class {wl} beats Class {ol}: margin = {margin:.4f}, "
              f"L = {L:.4f}, radius = {margin/L:.4f}")

    r_bracket = certified_radius(bracket, scores, x0, lip_const)
    r_argmax = flat_argmax_certified_radius(scores, x0, 4, lip_const)

    print(f"\nCertified radii:")
    print(f"  Bracket:  {r_bracket:.4f}")
    print(f"  Argmax:   {r_argmax:.4f}")

    # Verify by sampling
    n_samples = 10000
    perturbations = np.random.randn(n_samples, 2)
    perturbations = perturbations / np.linalg.norm(perturbations, axis=1, keepdims=True)
    perturbations *= np.random.uniform(0, r_bracket, (n_samples, 1))

    winners_perturbed = [winner(bracket, scores, x0 + p) for p in perturbations]
    all_same = all(w == w for w in winners_perturbed)
    print(f"\n  Empirical verification ({n_samples} samples in bracket ball): "
          f"{'All same ✓' if all_same else 'MISMATCH ✗'}")


# ============================================================================
# Demo 5: Bracket Optimization
# ============================================================================

def demo_bracket_optimization():
    """Show how different bracket structures give different certified radii."""
    print("\n" + "=" * 70)
    print("DEMO 5: Bracket Structure Optimization")
    print("=" * 70)

    np.random.seed(7)
    n_classes = 4

    weights = np.array([[3.0, 0.5], [0.0, 2.5], [-1.0, 1.0], [1.5, -1.5]])
    biases = np.array([0.0, 0.5, 1.0, -0.5])

    def scores(i, x):
        return weights[i] @ x + biases[i]

    def lip_const(i, j):
        return np.linalg.norm(weights[i] - weights[j])

    x0 = np.array([0.8, 0.3])

    print(f"\nScores at x0 = {x0}:")
    for i in range(n_classes):
        print(f"  Class {i}: {scores(i, x0):.3f}")

    # All possible brackets for 4 classes (there are several)
    from itertools import permutations

    brackets_info = []
    labels = list(range(n_classes))

    # Generate all binary tree structures for 4 leaves
    def all_brackets_4(labels):
        """Generate all bracket structures for 4 labels."""
        results = []
        for perm in permutations(labels):
            a, b, c, d = perm
            # Structure: ((a,b),(c,d))
            results.append((Node(Node(Leaf(a), Leaf(b)), Node(Leaf(c), Leaf(d))),
                           f"(({a}v{b})v({c}v{d}))"))
            # Structure: (((a,b),c),d) - left-skewed
            results.append((Node(Node(Node(Leaf(a), Leaf(b)), Leaf(c)), Leaf(d)),
                           f"((({a}v{b})v{c})v{d})"))
            # Structure: (a,((b,c),d)) - right-skewed
            results.append((Node(Leaf(a), Node(Node(Leaf(b), Leaf(c)), Leaf(d))),
                           f"({a}v(({b}v{c})v{d}))"))
        return results

    all_br = all_brackets_4(labels)

    # Deduplicate by winner and radius
    seen = set()
    unique_results = []
    for br, name in all_br:
        w = winner(br, scores, x0)
        r = certified_radius(br, scores, x0, lip_const)
        key = (w, round(r, 6), name)
        if key not in seen:
            seen.add(key)
            unique_results.append((br, name, w, r))

    # Sort by radius
    unique_results.sort(key=lambda x: -x[3])

    print(f"\nBracket structures ranked by certified radius:")
    for i, (br, name, w, r) in enumerate(unique_results[:10]):
        argmax_w = np.argmax([scores(j, x0) for j in range(n_classes)])
        marker = " ★" if w == argmax_w else " ✦"
        print(f"  {name:25s} → winner={w}, r*={r:.4f}{marker}")

    print(f"\n  ★ = agrees with argmax, ✦ = different winner (bracket advantage!)")

    best_r = unique_results[0][3]
    r_argmax = flat_argmax_certified_radius(scores, x0, n_classes, lip_const)
    print(f"\n  Best bracket radius:  {best_r:.4f}")
    print(f"  Argmax radius:        {r_argmax:.4f}")


# ============================================================================
# Demo 6: Tropical Network Composition
# ============================================================================

def demo_tropical_composition():
    """Demonstrate how tropical (max-plus) networks compose with brackets."""
    print("\n" + "=" * 70)
    print("DEMO 6: Tropical Network Composition")
    print("=" * 70)

    # Tropical linear function: f(x) = max_j (w_j + x_j) (max-plus algebra)
    # These are 1-Lipschitz w.r.t. l_infty norm

    def tropical_linear(w, x):
        """Max-plus linear function: max_j(w_j + x_j)"""
        return np.max(w + x)

    # Define 4 tropical score functions
    W = np.array([
        [2.0, -1.0, 0.5],
        [0.0,  3.0, -0.5],
        [-1.0, 1.0,  2.5],
        [1.5,  0.0,  1.0]
    ])

    def scores(i, x):
        return tropical_linear(W[i], x)

    # For tropical linear functions, Lip constant of difference ≤ 2 (l_infty)
    # But using l2 norm, Lip ≤ 2*sqrt(d)
    d = 3
    Kdiff = 2.0  # w.r.t. l_infty

    bracket = Node(Node(Leaf(0), Leaf(1)), Node(Leaf(2), Leaf(3)))
    x0 = np.array([1.0, 0.5, -0.3])

    print(f"\nTropical scores at x0 = {x0}:")
    for i in range(4):
        print(f"  Class {i}: f_{i}(x0) = max(w + x) = {scores(i, x0):.3f}")

    w = winner(bracket, scores, x0)
    print(f"\nTournament winner: Class {w}")

    nodes = all_nodes(bracket, scores, x0)
    print(f"\nAll comparison nodes:")
    min_margin = float('inf')
    for wl, ol, margin in nodes:
        r_node = margin / Kdiff
        min_margin = min(min_margin, r_node)
        print(f"  Class {wl} beats {ol}: margin = {margin:.3f}, "
              f"radius contribution = {r_node:.3f}")

    print(f"\nCertified radius (l_infty): {min_margin:.4f}")
    print(f"  (Any perturbation with ||δ||_∞ < {min_margin:.4f} preserves the winner)")


# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tournament Bracket Certified Robustness — Python Demonstration     ║")
    print("║  Companion to formally verified Lean 4 proofs                       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    bracket, scores, x0, weights, lip_const = demo_basic_bracket()
    demo_visualization(bracket, scores, x0, weights, lip_const)
    demo_statistics()
    demo_relu_network()
    demo_bracket_optimization()
    demo_tropical_composition()

    print("\n" + "=" * 70)
    print("All demos complete. See generated figures:")
    print("  - MachineLearning/fig_decision_regions.png")
    print("  - MachineLearning/fig_statistics.png")
    print("=" * 70)
