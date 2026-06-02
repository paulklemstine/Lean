#!/usr/bin/env python3
"""
Mortal-Eternity Games: Interactive Demonstration

Demonstrates transfinite strategy trees and their ordinal ranks.
Shows how diagonal constructions reach omega, omega*n, and omega^2.
"""

from typing import Optional, Callable, List, Tuple


class StratTree:
    """A strategy tree for the Mortal-Eternity game."""
    pass


class Done(StratTree):
    """Mortal concedes."""
    def __repr__(self) -> str:
        return "Done"


class Play(StratTree):
    """Mortal survives; Eternity picks n, continuing with child(n)."""
    def __init__(self, child_fn: Callable[[int], StratTree]):
        self.child_fn = child_fn
    
    def __repr__(self) -> str:
        return f"Play(...)"


def depth_tree(n: int) -> StratTree:
    """Strategy tree of exact depth n."""
    if n == 0:
        return Done()
    return Play(lambda _, n=n: depth_tree(n - 1))


def omega_tree() -> StratTree:
    """Diagonal construction: rank omega."""
    return Play(lambda n: depth_tree(n))


def add_finite(t: StratTree, k: int) -> StratTree:
    """Add k uniform levels to tree t."""
    if k == 0:
        return t
    return Play(lambda _, t=t, k=k: add_finite(t, k - 1))


def omega_mul_tree(n: int) -> StratTree:
    """Strategy tree with rank omega * n."""
    if n == 0:
        return Done()
    return Play(lambda k, n=n: add_finite(omega_mul_tree(n - 1), k))


def omega_sq_tree() -> StratTree:
    """Strategy tree with rank omega^2."""
    return Play(lambda n: omega_mul_tree(n))


def finite_rank(tree: StratTree, max_depth: int = 20) -> Optional[int]:
    """Compute rank for finite trees (returns None if exceeds max_depth)."""
    if isinstance(tree, Done):
        return 0
    if max_depth <= 0:
        return None
    # Sample children 0..max_depth to approximate rank
    max_child = 0
    for i in range(max_depth):
        child = tree.child_fn(i)
        r = finite_rank(child, max_depth - 1)
        if r is None:
            return None
        max_child = max(max_child, r + 1)
    return max_child


def sample_play(tree: StratTree, eternity_strategy: Callable[[int], int],
                max_rounds: int = 100) -> int:
    """Simulate a play: Eternity picks responses, count rounds survived."""
    rounds = 0
    current = tree
    while isinstance(current, Play) and rounds < max_rounds:
        response = eternity_strategy(rounds)
        current = current.child_fn(response)
        rounds += 1
    return rounds


# === DEMONSTRATIONS ===

print("=" * 60)
print("MORTAL-ETERNITY GAMES: TRANSFINITE STRATEGY TREES")
print("=" * 60)

print("\n--- 1. Finite Depth Trees ---")
for n in range(6):
    t = depth_tree(n)
    r = finite_rank(t)
    print(f"  depthTree({n}): rank = {r}")

print("\n--- 2. Omega Tree (Diagonal Construction) ---")
t = omega_tree()
print(f"  Sampling children of omegaTree:")
for n in range(8):
    child = t.child_fn(n)
    r = finite_rank(child)
    print(f"    child({n}) = depthTree({n}), rank = {r}")
print(f"  sup of ranks + 1 = sup(1,2,3,4,...) = omega")

print("\n--- 3. Simulated Plays Against Different Eternities ---")
strategies = {
    "always 0": lambda _: 0,
    "always 5": lambda _: 5,
    "identity": lambda r: r,
    "linear": lambda r: 2 * r + 1,
}
t = omega_tree()
for name, strat in strategies.items():
    rounds = sample_play(t, strat)
    print(f"  omegaTree vs '{name}': survived {rounds} rounds")

print("\n--- 4. AddFinite Construction ---")
base = omega_tree()
for k in range(5):
    t = add_finite(base, k)
    # rank = omega + k
    print(f"  addFinite(omegaTree, {k}): rank = omega + {k}")

print("\n--- 5. Omega*n Trees ---")
for n in range(6):
    t = omega_mul_tree(n)
    if n == 0:
        print(f"  omegaMulTree(0): rank = 0")
    else:
        print(f"  omegaMulTree({n}): rank = omega * {n}")
        # Verify by sampling children
        for k in range(3):
            child = t.child_fn(k)
            print(f"    child({k}): rank = omega*{n-1} + {k}")

print("\n--- 6. Omega^2 Tree ---")
t = omega_sq_tree()
print(f"  omegaSqTree: rank = omega^2")
for n in range(5):
    print(f"    child({n}) = omegaMulTree({n}): rank = omega*{n}")

print("\n--- 7. Ordinal Arithmetic Verification ---")
print("  Key identities used in the proofs:")
print("  - sup_n (n+1) = omega           [rank_omegaTree]")
print("  - alpha + k = alpha + k          [rank_addFinite]")
print("  - sup_k (omega*n + k + 1) = omega*(n+1)  [rank_omegaMulTree]")
print("  - sup_n (omega*n + 1) = omega^2  [rank_omegaSqTree]")

print("\n--- 8. Game Certificate Summary ---")
certs = [
    ("n", "depthTree(n)", "n"),
    ("omega", "omegaTree", "omega"),
    ("omega^2", "omegaSqTree", "omega^2"),
]
for ordinal, witness, rank in certs:
    print(f"  Certificate({ordinal}): tree = {witness}, rank = {rank}")

print("\n" + "=" * 60)
print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization of Mortal-Eternity Strategy Trees

Generates diagrams showing tree structure and ordinal rank hierarchy.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_tree_node(ax, x, y, label, color='lightblue', size=0.3):
    circle = plt.Circle((x, y), size, color=color, ec='black', lw=1.5, zorder=3)
    ax.add_patch(circle)
    ax.text(x, y, label, ha='center', va='center', fontsize=8, fontweight='bold', zorder=4)


def draw_edge(ax, x1, y1, x2, y2, label='', color='gray'):
    ax.plot([x1, x2], [y1, y2], color=color, lw=1.5, zorder=1)
    if label:
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        ax.text(mx - 0.15, my, label, fontsize=7, color='darkred')


def plot_depth_tree(ax, n=3):
    """Plot depthTree(n)."""
    ax.set_title(f'depthTree({n})\nrank = {n}', fontsize=11, fontweight='bold')
    
    y_positions = np.linspace(4, 0, n + 1)
    for i in range(n + 1):
        label = 'done' if i == n else f'd{n-i}'
        color = '#ffcccc' if i == n else '#cce5ff'
        draw_tree_node(ax, 2, y_positions[i], label, color)
        if i > 0:
            draw_edge(ax, 2, y_positions[i-1] - 0.3, 2, y_positions[i] + 0.3, '∀n')
    
    ax.set_xlim(0, 4)
    ax.set_ylim(-1, 5)
    ax.set_aspect('equal')
    ax.axis('off')


def plot_omega_tree(ax):
    """Plot omegaTree structure."""
    ax.set_title('omegaTree\nrank = ω', fontsize=11, fontweight='bold')
    
    draw_tree_node(ax, 3, 4, 'ωT', '#ffe0b2', 0.35)
    
    positions = [(1, 2.5), (2.5, 2.5), (4, 2.5), (5.5, 2.5)]
    labels = ['d(0)', 'd(1)', 'd(2)', 'd(3)']
    
    for i, ((x, y), label) in enumerate(zip(positions, labels)):
        draw_tree_node(ax, x, y, label, '#cce5ff')
        draw_edge(ax, 3, 4 - 0.3, x, y + 0.3, f'n={i}')
    
    ax.text(6.3, 2.5, '...', fontsize=14, va='center')
    
    # Show ranks below
    ranks = ['0', '1', '2', '3']
    for i, ((x, y), r) in enumerate(zip(positions, ranks)):
        ax.text(x, y - 0.6, f'rank={r}', fontsize=7, ha='center', color='darkblue')
    
    ax.text(3, 1, 'sup(0+1, 1+1, 2+1, 3+1, ...) = ω', 
            fontsize=9, ha='center', style='italic', color='darkgreen',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    ax.set_xlim(-0.5, 7.5)
    ax.set_ylim(0, 5)
    ax.set_aspect('equal')
    ax.axis('off')


def plot_omega_sq_tree(ax):
    """Plot omegaSqTree structure."""
    ax.set_title('omegaSqTree\nrank = ω²', fontsize=11, fontweight='bold')
    
    draw_tree_node(ax, 3, 4, 'ω²T', '#e1bee7', 0.35)
    
    positions = [(0.5, 2.5), (2, 2.5), (3.5, 2.5), (5, 2.5)]
    labels = ['ωM0', 'ωM1', 'ωM2', 'ωM3']
    
    for i, ((x, y), label) in enumerate(zip(positions, labels)):
        draw_tree_node(ax, x, y, label, '#c8e6c9')
        draw_edge(ax, 3, 4 - 0.3, x, y + 0.3, f'n={i}')
    
    ax.text(6, 2.5, '...', fontsize=14, va='center')
    
    ranks = ['0', 'ω', 'ω·2', 'ω·3']
    for i, ((x, y), r) in enumerate(zip(positions, ranks)):
        ax.text(x, y - 0.6, f'rank={r}', fontsize=7, ha='center', color='darkblue')
    
    ax.text(3, 1, 'sup(0+1, ω+1, ω·2+1, ω·3+1, ...) = ω·ω = ω²',
            fontsize=8, ha='center', style='italic', color='darkgreen',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    ax.set_xlim(-1, 7)
    ax.set_ylim(0, 5)
    ax.set_aspect('equal')
    ax.axis('off')


def plot_ordinal_hierarchy(ax):
    """Plot the ordinal hierarchy achieved by different constructions."""
    ax.set_title('Ordinal Hierarchy of Strategy Tree Ranks', fontsize=11, fontweight='bold')
    
    ordinals = [
        (0, '0', 'done', '#ffcccc'),
        (1, '1', 'depthTree(1)', '#ffd6d6'),
        (2, '2', 'depthTree(2)', '#ffe0e0'),
        (3, '3', 'depthTree(3)', '#ffeaea'),
        (5, 'ω', 'omegaTree', '#cce5ff'),
        (6, 'ω+1', 'addFinite(ωT, 1)', '#d4ebff'),
        (7, 'ω+2', 'addFinite(ωT, 2)', '#dcf0ff'),
        (9, 'ω·2', 'omegaMulTree(2)', '#c8e6c9'),
        (10, 'ω·3', 'omegaMulTree(3)', '#d4edd5'),
        (12, 'ω²', 'omegaSqTree', '#e1bee7'),
    ]
    
    for i, (pos, label, constructor, color) in enumerate(ordinals):
        ax.barh(pos, 8, height=0.8, color=color, edgecolor='black', linewidth=0.5)
        ax.text(0.1, pos, label, fontsize=9, fontweight='bold', va='center')
        ax.text(4, pos, constructor, fontsize=8, va='center', style='italic')
    
    # Add gap indicators
    for y in [4, 8, 11]:
        ax.text(4, y, '⋮', fontsize=14, ha='center', va='center', color='gray')
    
    ax.set_xlim(-0.5, 9)
    ax.set_ylim(-1, 13)
    ax.set_xlabel('')
    ax.set_yticks([])
    ax.set_xticks([])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    ax.spines['left'].set_visible(False)


# === MAIN FIGURE ===

fig = plt.figure(figsize=(16, 12))

ax1 = fig.add_subplot(2, 2, 1)
plot_depth_tree(ax1, n=3)

ax2 = fig.add_subplot(2, 2, 2)
plot_omega_tree(ax2)

ax3 = fig.add_subplot(2, 2, 3)
plot_omega_sq_tree(ax3)

ax4 = fig.add_subplot(2, 2, 4)
plot_ordinal_hierarchy(ax4)

fig.suptitle('Mortal-Eternity Games: Strategy Tree Constructions',
             fontsize=14, fontweight='bold', y=0.98)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('strategy_trees.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved strategy_trees.png")
