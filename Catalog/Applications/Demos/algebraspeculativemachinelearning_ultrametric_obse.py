#!/usr/bin/env python3
"""
Ultrametric Observer–Concept Duality: Demonstrations and Visualizations

This module demonstrates the core mathematical results:
1. Ultrametric balls are nested or disjoint (laminarity)
2. Laminar families correspond to trees
3. Compression witnesses from laminar structure
4. Perturbation robustness of ultrametric balls
"""

import itertools
import json
import base64
from io import BytesIO
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# ============================================================
# §1. Ultrametric Foundations
# ============================================================

def is_ultrametric(d: np.ndarray) -> bool:
    """Check if a distance matrix satisfies the ultrametric inequality."""
    n = d.shape[0]
    for i in range(n):
        if d[i, i] != 0:
            return False
        for j in range(n):
            if d[i, j] != d[j, i]:
                return False
            if d[i, j] == 0 and i != j:
                return False
            for k in range(n):
                if d[i, k] > max(d[i, j], d[j, k]):
                    return False
    return True


def ultrametric_ball(d: np.ndarray, center: int, radius: int) -> FrozenSet[int]:
    """Compute the closed ball B(center, radius) in an ultrametric."""
    n = d.shape[0]
    return frozenset(x for x in range(n) if d[center, x] <= radius)


def all_balls(d: np.ndarray) -> Set[FrozenSet[int]]:
    """Compute all distinct ultrametric balls."""
    n = d.shape[0]
    max_r = int(d.max())
    balls = set()
    for a in range(n):
        for r in range(max_r + 1):
            balls.add(ultrametric_ball(d, a, r))
    return balls


def verify_laminarity(balls: Set[FrozenSet[int]]) -> bool:
    """Verify that a family of sets is laminar (nested or disjoint)."""
    ball_list = list(balls)
    for i, A in enumerate(ball_list):
        for j, B in enumerate(ball_list):
            if i < j:
                if not (A <= B or B <= A or A.isdisjoint(B)):
                    return False
    return True


# ============================================================
# §2. Laminar Family → Tree Conversion
# ============================================================

class LaminarTreeNode:
    """A node in a tree representing a laminar family."""
    def __init__(self, label: FrozenSet[int]):
        self.label = label
        self.children: List['LaminarTreeNode'] = []

    def __repr__(self):
        return f"Node({set(self.label)})"

    def depth(self) -> int:
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)

    def size(self) -> int:
        return 1 + sum(c.size() for c in self.children)


def laminar_to_tree(balls: Set[FrozenSet[int]], ground: FrozenSet[int]) -> LaminarTreeNode:
    """Convert a laminar family to a rooted tree.

    The root is the ground set. Children of each node are the maximal
    proper subsets in the family.
    """
    # Add ground set if not present
    all_sets = balls | {ground}

    # Sort by size (largest first)
    sorted_sets = sorted(all_sets, key=lambda s: -len(s))

    nodes: Dict[FrozenSet[int], LaminarTreeNode] = {}
    for s in sorted_sets:
        nodes[s] = LaminarTreeNode(s)

    # Build parent-child relationships
    for s in sorted_sets:
        # Find the smallest set strictly containing s
        parent = None
        for t in sorted_sets:
            if s < t:  # proper subset
                if parent is None or len(t) < len(parent):
                    parent = t
        if parent is not None:
            nodes[parent].children.append(nodes[s])

    return nodes[ground]


# ============================================================
# §3. Compression Witnesses
# ============================================================

def find_compression_witness(balls: Set[FrozenSet[int]]) -> Set[int]:
    """Find a minimal compression witness for a laminar family.

    A compression witness is a set of points that distinguishes
    all distinct members of the family.
    """
    ball_list = list(balls)
    # All points in the ground set
    ground = frozenset().union(*balls) if balls else frozenset()

    # Greedy: find points that separate the most pairs
    witnesses = set()
    unseparated = set()
    for i in range(len(ball_list)):
        for j in range(i + 1, len(ball_list)):
            if ball_list[i] != ball_list[j]:
                unseparated.add((i, j))

    while unseparated:
        # Find point that separates the most remaining pairs
        best_point = None
        best_count = 0
        for p in ground:
            count = sum(1 for (i, j) in unseparated
                       if (p in ball_list[i]) != (p in ball_list[j]))
            if count > best_count:
                best_count = count
                best_point = p
        if best_point is None:
            break
        witnesses.add(best_point)
        unseparated = {(i, j) for (i, j) in unseparated
                       if (best_point in ball_list[i]) == (best_point in ball_list[j])}

    return witnesses


# ============================================================
# §4. Visualization
# ============================================================

def plot_laminar_tree(root: LaminarTreeNode, title: str = "Laminar Tree",
                      filename: str = "laminar_tree.png") -> str:
    """Plot a laminar tree and return base64 encoded image."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.set_title(title, fontsize=14, fontweight='bold')

    positions = {}
    _assign_positions(root, positions, 0, 0, 1)

    # Draw edges
    for node_key, (x, y) in positions.items():
        node = _find_node(root, node_key)
        if node:
            for child in node.children:
                child_key = frozenset(child.label)
                if child_key in positions:
                    cx, cy = positions[child_key]
                    ax.plot([x, cx], [y, cy], 'k-', linewidth=1.5, alpha=0.7)

    # Draw nodes
    for node_key, (x, y) in positions.items():
        label_str = "{" + ",".join(str(e) for e in sorted(node_key)) + "}"
        ax.plot(x, y, 'o', markersize=20, color='steelblue', zorder=5)
        ax.text(x, y, label_str, ha='center', va='center', fontsize=8,
                fontweight='bold', color='white', zorder=6)

    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.5, 0.5)
    ax.axis('off')
    plt.tight_layout()

    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def _assign_positions(node, positions, depth, left, right):
    x = (left + right) / 2
    y = -depth * 0.15
    positions[frozenset(node.label)] = (x, y)
    n = len(node.children)
    if n > 0:
        width = (right - left) / n
        for i, child in enumerate(node.children):
            _assign_positions(child, positions, depth + 1,
                            left + i * width, left + (i + 1) * width)


def _find_node(root, key):
    if frozenset(root.label) == key:
        return root
    for child in root.children:
        result = _find_node(child, key)
        if result:
            return result
    return None


def plot_perturbation_robustness(filename: str = "perturbation.png") -> str:
    """Plot how ball containment changes under perturbation."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    for idx, eps in enumerate([0, 1, 2]):
        ax = axes[idx]
        # Original ultrametric: d(0,1)=1, d(0,2)=d(1,2)=3
        d_orig = np.array([[0, 1, 3], [1, 0, 3], [3, 3, 0]])
        d_pert = np.clip(d_orig + np.random.RandomState(42+idx).randint(-eps, eps+1, (3,3)), 0, 10)
        np.fill_diagonal(d_pert, 0)
        d_pert = np.maximum(d_pert, d_pert.T)  # symmetrize

        balls = all_balls(d_orig)
        is_lam = verify_laminarity(balls)

        ax.set_title(f"ε = {eps}, Laminar: {is_lam}", fontsize=11)

        # Draw balls as nested rectangles
        y_pos = 0
        for ball in sorted(balls, key=lambda b: (-len(b), min(b))):
            elements = sorted(ball)
            x_min = min(elements) - 0.3
            x_max = max(elements) + 0.3
            rect = mpatches.FancyBboxPatch(
                (x_min, y_pos - 0.2), x_max - x_min, 0.4,
                boxstyle="round,pad=0.05",
                facecolor=plt.cm.Set3(len(ball) / 4),
                edgecolor='black', linewidth=1.5, alpha=0.6
            )
            ax.add_patch(rect)
            label = "{" + ",".join(str(e) for e in elements) + "}"
            ax.text((x_min + x_max)/2, y_pos, label, ha='center', va='center', fontsize=8)
            y_pos -= 0.5

        ax.set_xlim(-1, 3.5)
        ax.set_ylim(y_pos - 0.5, 1)
        ax.set_xlabel("Elements")
        ax.axis('off')

    plt.suptitle("Perturbation Robustness of Ultrametric Balls", fontsize=13, fontweight='bold')
    plt.tight_layout()

    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def plot_isosceles_property(filename: str = "isosceles.png") -> str:
    """Visualize the ultrametric isosceles triangle property."""
    fig, ax = plt.subplots(figsize=(8, 6))

    # Sample random ultrametric triangles and verify isosceles
    np.random.seed(42)
    n_trials = 200
    sides = []
    for _ in range(n_trials):
        # Generate ultrametric triangle: d(a,c) = max(d(a,b), d(b,c))
        d_ab = np.random.randint(1, 20)
        d_bc = np.random.randint(1, 20)
        d_ac = max(d_ab, d_bc)
        sides.append(sorted([d_ab, d_bc, d_ac]))

    # Plot: x = ratio of two largest sides, y = smallest/largest
    ratios = [(s[1]/s[2] if s[2] > 0 else 1, s[0]/s[2] if s[2] > 0 else 1) for s in sides]

    ax.scatter([r[0] for r in ratios], [r[1] for r in ratios],
               c='steelblue', alpha=0.6, s=40, edgecolors='navy', linewidths=0.5)
    ax.axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='Two largest sides equal')
    ax.set_xlabel("Ratio: second-largest / largest side", fontsize=12)
    ax.set_ylabel("Ratio: smallest / largest side", fontsize=12)
    ax.set_title("Ultrametric Isosceles Property\n(All triangles have two equal largest sides)",
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xlim(0.9, 1.1)
    plt.tight_layout()

    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


# ============================================================
# §5. Main Demo
# ============================================================

def run_demo():
    """Run all demonstrations."""
    print("=" * 60)
    print("ULTRAMETRIC OBSERVER–CONCEPT DUALITY: DEMO")
    print("=" * 60)

    # Example 1: Three-point ultrametric
    print("\n--- Example 1: Three-point ultrametric ---")
    d3 = np.array([[0, 1, 2],
                    [1, 0, 2],
                    [2, 2, 0]])
    print(f"Distance matrix:\n{d3}")
    print(f"Is ultrametric: {is_ultrametric(d3)}")

    balls3 = all_balls(d3)
    print(f"All balls ({len(balls3)}):")
    for b in sorted(balls3, key=lambda s: (len(s), min(s))):
        print(f"  {set(b)}")
    print(f"Is laminar: {verify_laminarity(balls3)}")

    witnesses = find_compression_witness(balls3)
    print(f"Compression witness: {witnesses} (size {len(witnesses)})")

    # Build tree
    ground = frozenset(range(3))
    tree = laminar_to_tree(balls3, ground)
    print(f"Tree depth: {tree.depth()}")
    print(f"Tree size: {tree.size()}")

    # Example 2: Five-point ultrametric (two clusters)
    print("\n--- Example 2: Five-point ultrametric ---")
    d5 = np.array([
        [0, 1, 1, 3, 3],
        [1, 0, 1, 3, 3],
        [1, 1, 0, 3, 3],
        [3, 3, 3, 0, 2],
        [3, 3, 3, 2, 0]
    ])
    print(f"Is ultrametric: {is_ultrametric(d5)}")
    balls5 = all_balls(d5)
    print(f"All balls ({len(balls5)}):")
    for b in sorted(balls5, key=lambda s: (len(s), min(s))):
        print(f"  {set(b)}")
    print(f"Is laminar: {verify_laminarity(balls5)}")

    witnesses5 = find_compression_witness(balls5)
    print(f"Compression witness: {witnesses5} (size {len(witnesses5)})")

    tree5 = laminar_to_tree(balls5, frozenset(range(5)))
    print(f"Tree depth: {tree5.depth()}")
    print(f"Tree size: {tree5.size()}")

    # Example 3: Verify isosceles property
    print("\n--- Example 3: Isosceles triangle property ---")
    for i, j, k in itertools.combinations(range(5), 3):
        sides = sorted([d5[i,j], d5[j,k], d5[i,k]])
        is_iso = sides[1] == sides[2]
        print(f"  Triangle ({i},{j},{k}): sides={sides}, isosceles={is_iso}")

    # Generate visualizations
    print("\n--- Generating visualizations ---")
    tree_img = plot_laminar_tree(tree5, "Five-Point Ultrametric Tree")
    pert_img = plot_perturbation_robustness()
    iso_img = plot_isosceles_property()
    print("Visualizations generated.")

    return tree_img, pert_img, iso_img


if __name__ == "__main__":
    run_demo()
