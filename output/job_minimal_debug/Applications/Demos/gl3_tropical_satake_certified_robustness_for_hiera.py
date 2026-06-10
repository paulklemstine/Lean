#!/usr/bin/env python3
"""
Hierarchical Classifier Robustness: Tournament Margin Decomposition Demo

This script demonstrates the formally verified robustness theory for
hierarchical multiclass classifiers built from binary elimination trees.

Key results demonstrated:
1. Tournament evaluation produces the global argmax
2. Global margin certificate: min margin over all nodes
3. Pathwise certificate: min margin along winner path only (sharper!)
4. Heterogeneous Lipschitz constants per node
5. Certified radius computation

All results are backed by machine-verified Lean 4 proofs.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from dataclasses import dataclass
from typing import List
import os

# ============================================================
# Binary Elimination Tree
# ============================================================

@dataclass
class HTree:
    """Binary elimination tree with labeled leaves."""
    pass

@dataclass
class Leaf(HTree):
    label: str

@dataclass
class Node(HTree):
    left: HTree
    right: HTree


def get_classes(tree: HTree) -> set:
    if isinstance(tree, Leaf):
        return {tree.label}
    return get_classes(tree.left) | get_classes(tree.right)


def evaluate(tree: HTree, scores: dict) -> str:
    if isinstance(tree, Leaf):
        return tree.label
    u = evaluate(tree.left, scores)
    v = evaluate(tree.right, scores)
    return u if scores[u] >= scores[v] else v


def path_margins(tree: HTree, scores: dict) -> List[float]:
    if isinstance(tree, Leaf):
        return []
    u = evaluate(tree.left, scores)
    v = evaluate(tree.right, scores)
    margin = abs(scores[u] - scores[v])
    if scores[u] >= scores[v]:
        return [margin] + path_margins(tree.left, scores)
    else:
        return [margin] + path_margins(tree.right, scores)


def all_margins(tree: HTree, scores: dict) -> List[float]:
    if isinstance(tree, Leaf):
        return []
    u = evaluate(tree.left, scores)
    v = evaluate(tree.right, scores)
    margin = abs(scores[u] - scores[v])
    return [margin] + all_margins(tree.left, scores) + all_margins(tree.right, scores)


def certified_radius(tree: HTree, scores: dict, lip_const: float) -> float:
    margins = all_margins(tree, scores)
    if not margins or lip_const <= 0:
        return 0.0
    return min(margins) / lip_const


def path_certified_radius(tree: HTree, scores: dict, lip_const: float) -> float:
    margins = path_margins(tree, scores)
    if not margins or lip_const <= 0:
        return 0.0
    return min(margins) / lip_const


# ============================================================
# LHTree: Labeled tree with per-node Lipschitz constants
# ============================================================

@dataclass
class LHTree:
    pass

@dataclass
class LLeaf(LHTree):
    label: str

@dataclass
class LNode(LHTree):
    lip_const: float
    left: LHTree
    right: LHTree


def levaluate(tree: LHTree, scores: dict) -> str:
    if isinstance(tree, LLeaf):
        return tree.label
    u = levaluate(tree.left, scores)
    v = levaluate(tree.right, scores)
    return u if scores[u] >= scores[v] else v


def lpath_certified_radius(tree: LHTree, scores: dict) -> float:
    if isinstance(tree, LLeaf):
        return float('inf')
    u = levaluate(tree.left, scores)
    v = levaluate(tree.right, scores)
    margin = abs(scores[u] - scores[v])
    local_radius = margin / tree.lip_const if tree.lip_const > 0 else float('inf')
    if scores[u] >= scores[v]:
        child_radius = lpath_certified_radius(tree.left, scores)
    else:
        child_radius = lpath_certified_radius(tree.right, scores)
    return min(local_radius, child_radius)


# ============================================================
# Demo 1: Basic Tournament Evaluation
# ============================================================

def demo_basic_evaluation():
    print("=" * 60)
    print("DEMO 1: Tournament Evaluation = Global Argmax")
    print("=" * 60)

    tree = Node(Node(Leaf("A"), Leaf("B")), Node(Leaf("C"), Leaf("D")))
    scores = {"A": 3.0, "B": 7.0, "C": 5.0, "D": 2.0}
    winner = evaluate(tree, scores)
    argmax = max(scores, key=scores.get)

    print(f"Scores: {scores}")
    print(f"Tournament winner: {winner}")
    print(f"Global argmax:     {argmax}")
    print(f"Match: {winner == argmax}  (Formally verified: eval_score_ge)")
    print()
    print("Tournament bracket:")
    print(f"  Semi 1: A({scores['A']}) vs B({scores['B']}) -> B wins")
    print(f"  Semi 2: C({scores['C']}) vs D({scores['D']}) -> C wins")
    print(f"  Final:  B({scores['B']}) vs C({scores['C']}) -> B wins")
    print()


# ============================================================
# Demo 2: Robustness Certificate Comparison
# ============================================================

def demo_robustness_comparison():
    print("=" * 60)
    print("DEMO 2: Global vs Pathwise Robustness Certificate")
    print("=" * 60)

    tree = Node(
        Node(Node(Leaf("A"), Leaf("B")), Node(Leaf("C"), Leaf("D"))),
        Node(Node(Leaf("E"), Leaf("F")), Node(Leaf("G"), Leaf("H")))
    )
    scores = {"A": 10.0, "B": 3.0, "C": 4.0, "D": 3.5,
              "E": 6.0, "F": 5.0, "G": 2.0, "H": 1.0}
    lip_const = 2.0

    winner = evaluate(tree, scores)
    r_global = certified_radius(tree, scores, lip_const)
    r_path = path_certified_radius(tree, scores, lip_const)

    print(f"Scores: {scores}")
    print(f"Winner: {winner}")
    print(f"All node margins:    {[f'{m:.1f}' for m in all_margins(tree, scores)]}")
    print(f"Path margins only:   {[f'{m:.1f}' for m in path_margins(tree, scores)]}")
    print(f"Global cert. radius:  {r_global:.3f}")
    print(f"Pathwise cert. radius: {r_path:.3f}")
    print(f"Improvement factor:   {r_path/r_global:.1f}x")
    print()
    print("The pathwise certificate is sharper because the C-vs-D")
    print("comparison (margin 0.5) is NOT on the winner path.")
    print()


# ============================================================
# Demo 3: Perturbation Visualization
# ============================================================

def demo_perturbation_visualization():
    print("=" * 60)
    print("DEMO 3: Perturbation Robustness Visualization")
    print("=" * 60)

    tree = Node(Node(Leaf("A"), Leaf("B")), Node(Leaf("C"), Leaf("D")))
    base_scores = {"A": 8.0, "B": 5.0, "C": 6.0, "D": 3.0}
    lip_const = 2.0

    r_path = path_certified_radius(tree, base_scores, lip_const)
    r_global = certified_radius(tree, base_scores, lip_const)

    n_trials = 5000
    perturbation_levels = np.linspace(0, 3.0, 40)
    stability_rates = []

    np.random.seed(42)
    for eps in perturbation_levels:
        stable = 0
        for _ in range(n_trials):
            perturbation = np.random.uniform(-eps, eps, 4)
            perturbed = {k: base_scores[k] + perturbation[i]
                        for i, k in enumerate(base_scores)}
            if evaluate(tree, perturbed) == evaluate(tree, base_scores):
                stable += 1
        stability_rates.append(stable / n_trials)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.plot(perturbation_levels, stability_rates, 'b-', linewidth=2,
            label='Empirical stability rate')
    ax.axvline(x=r_global, color='red', linestyle='--', linewidth=2,
               label=f'Global cert. radius = {r_global:.2f}')
    ax.axvline(x=r_path, color='green', linestyle='--', linewidth=2,
               label=f'Pathwise cert. radius = {r_path:.2f}')
    ax.fill_betweenx([0, 1.1], 0, r_path, alpha=0.1, color='green')
    ax.set_xlabel('Perturbation magnitude (L∞)', fontsize=12)
    ax.set_ylabel('Probability of unchanged winner', fontsize=12)
    ax.set_title('Certified Robustness of Tournament Classifier\n'
                 '(Green region: formally guaranteed stable)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(-0.05, 1.1)
    ax.set_xlim(0, 3.0)
    plt.tight_layout()
    plt.savefig('demos/perturbation_robustness.png', dpi=150)
    print("Saved: demos/perturbation_robustness.png")
    plt.close()
    print()


# ============================================================
# Demo 4: Heterogeneous Lipschitz Constants
# ============================================================

def demo_heterogeneous_lipschitz():
    print("=" * 60)
    print("DEMO 4: Heterogeneous Lipschitz Constants")
    print("=" * 60)

    tree_uniform = Node(Node(Leaf("A"), Leaf("B")), Node(Leaf("C"), Leaf("D")))
    ltree = LNode(1.0,
        LNode(3.0, LLeaf("A"), LLeaf("B")),
        LNode(2.0, LLeaf("C"), LLeaf("D"))
    )
    scores = {"A": 10.0, "B": 6.0, "C": 7.0, "D": 3.0}
    global_lip = 3.0

    r_uniform = path_certified_radius(tree_uniform, scores, global_lip)
    r_hetero = lpath_certified_radius(ltree, scores)

    print(f"Scores: {scores}")
    print(f"Winner: {evaluate(tree_uniform, scores)}")
    print(f"Uniform Lipschitz ({global_lip}):  cert. radius = {r_uniform:.3f}")
    print(f"Heterogeneous Lipschitz:    cert. radius = {r_hetero:.3f}")
    print(f"Improvement: {r_hetero/r_uniform:.1f}x")
    print()
    print("Per-node analysis:")
    print(f"  Root:  margin={abs(scores['A']-scores['C']):.1f}, lip=1.0, "
          f"local_radius={abs(scores['A']-scores['C'])/1.0:.1f}")
    print(f"  Semi1: margin={abs(scores['A']-scores['B']):.1f}, lip=3.0, "
          f"local_radius={abs(scores['A']-scores['B'])/3.0:.2f}")
    print(f"  Semi2: margin={abs(scores['C']-scores['D']):.1f}, lip=2.0, "
          f"local_radius={abs(scores['C']-scores['D'])/2.0:.1f}")
    print()


# ============================================================
# Demo 5: Scaling with Tree Depth
# ============================================================

def demo_depth_scaling():
    print("=" * 60)
    print("DEMO 5: Certificate Scaling with Tree Depth")
    print("=" * 60)

    depths = range(1, 8)
    n_classes_list = [2**d for d in depths]
    global_radii = []
    path_radii = []
    lip_const = 2.0

    for depth in depths:
        n = 2**depth
        labels = [f"C{i}" for i in range(n)]
        scores = {labels[i]: float(n - i) for i in range(n)}

        def build_balanced(lst):
            if len(lst) == 1:
                return Leaf(lst[0])
            mid = len(lst) // 2
            return Node(build_balanced(lst[:mid]), build_balanced(lst[mid:]))

        tree = build_balanced(labels)
        global_radii.append(certified_radius(tree, scores, lip_const))
        path_radii.append(path_certified_radius(tree, scores, lip_const))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    ax1.plot(n_classes_list, global_radii, 'ro-', linewidth=2, markersize=8,
             label='Global certificate')
    ax1.plot(n_classes_list, path_radii, 'gs-', linewidth=2, markersize=8,
             label='Pathwise certificate')
    ax1.set_xlabel('Number of classes', fontsize=12)
    ax1.set_ylabel('Certified radius', fontsize=12)
    ax1.set_title('Certificate vs. Number of Classes', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.set_xscale('log', base=2)

    ratios = [p/g if g > 0 else 1 for p, g in zip(path_radii, global_radii)]
    ax2.bar(range(len(list(depths))), ratios, color='purple', alpha=0.7)
    ax2.set_xticks(range(len(list(depths))))
    ax2.set_xticklabels([f'{n}' for n in n_classes_list])
    ax2.set_xlabel('Number of classes', fontsize=12)
    ax2.set_ylabel('Pathwise / Global ratio', fontsize=12)
    ax2.set_title('Improvement Factor of Pathwise Certificate', fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/depth_scaling.png', dpi=150)
    print("Saved: demos/depth_scaling.png")
    plt.close()
    print()


# ============================================================
# Demo 6: Application — Hierarchical Image Classifier
# ============================================================

def demo_application():
    print("=" * 60)
    print("DEMO 6: Application — Hierarchical Image Classifier")
    print("=" * 60)

    tree = Node(
        Node(Node(Leaf("Cat"), Leaf("Dog")), Leaf("Bird")),
        Leaf("Car")
    )
    scores = {"Cat": 4.2, "Dog": 2.8, "Bird": 1.5, "Car": -1.0}
    lip_const = 1.5

    winner = evaluate(tree, scores)
    r_path = path_certified_radius(tree, scores, lip_const)
    r_global = certified_radius(tree, scores, lip_const)

    print(f"Classification: {winner}")
    print(f"Score profile: {scores}")
    print(f"Path margins: {[f'{m:.1f}' for m in path_margins(tree, scores)]}")
    print(f"Certified radius (pathwise): {r_path:.3f}")
    print(f"Certified radius (global):   {r_global:.3f}")
    print()
    print("Any input perturbation with L-infinity distance")
    print(f"<= {r_path:.3f} is GUARANTEED to not change the classification.")
    print()


# ============================================================
# Demo 7: Tree Visualization
# ============================================================

def demo_tree_visualization():
    print("=" * 60)
    print("DEMO 7: Tournament Tree Visualization")
    print("=" * 60)

    tree = Node(
        Node(Node(Leaf("A"), Leaf("B")), Node(Leaf("C"), Leaf("D"))),
        Node(Node(Leaf("E"), Leaf("F")), Leaf("G"))
    )
    scores = {"A": 9.0, "B": 4.0, "C": 7.0, "D": 6.0,
              "E": 3.0, "F": 5.0, "G": 2.0}

    fig, ax = plt.subplots(1, 1, figsize=(14, 8))

    def draw_tree(t, x, y, dx, is_wp=True):
        if isinstance(t, Leaf):
            overall_winner = evaluate(tree, scores)
            c = 'gold' if t.label == overall_winner else ('lightgreen' if is_wp else 'lightblue')
            ax.add_patch(plt.Circle((x, y), 0.3, color=c, ec='black', lw=2, zorder=5))
            ax.text(x, y, f"{t.label}\n{scores[t.label]:.0f}",
                    ha='center', va='center', fontsize=10, fontweight='bold', zorder=6)
            return

        u = evaluate(t.left, scores)
        v = evaluate(t.right, scores)
        margin = abs(scores[u] - scores[v])
        left_wins = scores[u] >= scores[v]

        draw_tree(t.left, x - dx, y - 1.5, dx/2, is_wp and left_wins)
        draw_tree(t.right, x + dx, y - 1.5, dx/2, is_wp and not left_wins)

        lc = 'green' if (is_wp and left_wins) else 'gray'
        rc = 'green' if (is_wp and not left_wins) else 'gray'
        llw = 3 if (is_wp and left_wins) else 1
        rlw = 3 if (is_wp and not left_wins) else 1

        ax.plot([x, x-dx], [y-0.3, y-1.2], color=lc, linewidth=llw, zorder=3)
        ax.plot([x, x+dx], [y-0.3, y-1.2], color=rc, linewidth=rlw, zorder=3)

        nc = 'lightgreen' if is_wp else 'lightyellow'
        ax.add_patch(plt.Circle((x, y), 0.3, color=nc, ec='black', lw=2, zorder=5))
        ax.text(x, y, f"Δ={margin:.0f}", ha='center', va='center', fontsize=9, zorder=6)

    draw_tree(tree, 7, 6, 3)

    legend_elements = [
        mpatches.Patch(facecolor='gold', edgecolor='black', label='Tournament Winner'),
        mpatches.Patch(facecolor='lightgreen', edgecolor='black', label='Winner Path'),
        mpatches.Patch(facecolor='lightblue', edgecolor='black', label='Non-path Leaves'),
        mpatches.Patch(facecolor='lightyellow', edgecolor='black', label='Non-path Nodes'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=10)
    ax.set_xlim(2, 12)
    ax.set_ylim(-1, 7.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Tournament Elimination Tree with Winner Path Highlighted\n'
                 'Green path = certified by pathMargin (sharper certificate)',
                 fontsize=14)
    plt.tight_layout()
    plt.savefig('demos/tournament_tree.png', dpi=150)
    print("Saved: demos/tournament_tree.png")
    plt.close()
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    os.makedirs('demos', exist_ok=True)

    demo_basic_evaluation()
    demo_robustness_comparison()
    demo_perturbation_visualization()
    demo_heterogeneous_lipschitz()
    demo_depth_scaling()
    demo_application()
    demo_tree_visualization()

    print("=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)
    print()
    print("Summary of formally verified theorems (Lean 4):")
    print("  1. HTree.eval_stable        — Global margin robustness")
    print("  2. HTree.eval_stable_of_pathDom — Pathwise domination robustness")
    print("  3. HTree.pathMargin_sufficient  — Path margin certificate")
    print("  4. HTree.eval_stable_of_lip     — Lipschitz parameterization")
    print("  5. HTree.robust_radius_spec     — Tropical Hecke-score version")
    print("  6. LHTree.eval_stable           — Heterogeneous Lipschitz")
    print("  7. HTree.eval_score_ge          — Tournament = global argmax")
    print("  8. HTree.allMarginsAbove_implies_pathDominates — Certificate hierarchy")
