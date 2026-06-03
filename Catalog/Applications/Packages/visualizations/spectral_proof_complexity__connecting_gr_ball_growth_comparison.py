#!/usr/bin/env python3
"""
Visualization: Proof Ball Growth Comparison

Compares ball growth across different derivation system topologies:
linear chain, binary tree, and cyclic expander.
"""
import matplotlib.pyplot as plt
import numpy as np
from typing import Dict, List, Set


def compute_ball_sizes(axioms: Set[int], derives: Dict[int, Set[int]], depth: int) -> List[int]:
    ball = set(axioms)
    sizes = [len(ball)]
    for _ in range(depth):
        frontier = set()
        for a in ball:
            frontier |= derives.get(a, set())
        ball = ball | frontier
        sizes.append(len(ball))
    return sizes


def compute_frontier_sizes(axioms: Set[int], derives: Dict[int, Set[int]], depth: int) -> List[int]:
    ball = set(axioms)
    sizes = []
    for _ in range(depth):
        frontier = set()
        for a in ball:
            frontier |= derives.get(a, set())
        frontier -= ball
        sizes.append(len(frontier))
        ball = ball | frontier
    return sizes


# Systems
n = 100
depth = 20

# Linear chain
linear_ax = {0}
linear_der = {i: {i + 1} for i in range(n)}
linear_sizes = compute_ball_sizes(linear_ax, linear_der, depth)
linear_fr = compute_frontier_sizes(linear_ax, linear_der, depth)

# Binary tree
tree_ax = {1}
tree_der = {i: {2*i, 2*i+1} for i in range(1, 2**7)}
tree_sizes = compute_ball_sizes(tree_ax, tree_der, min(depth, 7))
tree_fr = compute_frontier_sizes(tree_ax, tree_der, min(depth, 7))

# Cyclic expander
exp_ax = {0}
exp_der = {i: {(i+1) % n, (i+3) % n, (i+7) % n} for i in range(n)}
exp_sizes = compute_ball_sizes(exp_ax, exp_der, depth)
exp_fr = compute_frontier_sizes(exp_ax, exp_der, depth)

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Ball sizes
ax1 = axes[0]
ax1.plot(range(len(linear_sizes)), linear_sizes, 'b-o', label='Linear chain', markersize=4)
ax1.plot(range(len(tree_sizes)), tree_sizes, 'r-s', label='Binary tree', markersize=4)
ax1.plot(range(len(exp_sizes)), exp_sizes, 'g-^', label='Cyclic expander', markersize=4)

# Additive lower bound for expander (min frontier = 3 in early steps)
lb_sizes = [1 + k * 3 for k in range(depth + 1)]
ax1.plot(range(len(lb_sizes)), lb_sizes, 'g--', alpha=0.5, label='Additive lower bound (c=3)')

ax1.set_xlabel('Depth k', fontsize=12)
ax1.set_ylabel('|Ball(k)|', fontsize=12)
ax1.set_title('Proof Ball Growth', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_yscale('log')

# Frontier sizes
ax2 = axes[1]
ax2.bar(np.arange(len(linear_fr)) - 0.25, linear_fr, 0.25, label='Linear', color='blue', alpha=0.7)
ax2.bar(np.arange(len(tree_fr)), tree_fr, 0.25, label='Binary tree', color='red', alpha=0.7)
ax2.bar(np.arange(min(len(exp_fr), 20)) + 0.25, exp_fr[:20], 0.25, label='Expander', color='green', alpha=0.7)

ax2.set_xlabel('Depth k', fontsize=12)
ax2.set_ylabel('|Frontier(k)|', fontsize=12)
ax2.set_title('Frontier Dynamics', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('ball_growth_comparison.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: ball_growth_comparison.png")

# Summary statistics
print("\nLinear chain:")
print(f"  Final ball size: {linear_sizes[-1]}")
print(f"  Stabilization: depth {next((k for k in range(len(linear_fr)) if linear_fr[k] == 0), 'none')}")

print("\nBinary tree:")
print(f"  Final ball size: {tree_sizes[-1]}")
print(f"  Max frontier: {max(tree_fr)}")

print("\nCyclic expander:")
print(f"  Final ball size: {exp_sizes[-1]}")
print(f"  Stabilization: depth {next((k for k in range(len(exp_fr)) if exp_fr[k] == 0), 'none')}")
