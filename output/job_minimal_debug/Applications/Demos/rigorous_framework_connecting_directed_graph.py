#!/usr/bin/env python3
"""
Spectral Proof Complexity — Demonstration

Demonstrates derivation systems, proof ball growth, frontier dynamics,
and depth lower bounds using concrete examples.
"""

from typing import Dict, FrozenSet, List, Set, Tuple


def compute_proof_balls(
    axioms: Set[int], derives: Dict[int, Set[int]], max_depth: int
) -> List[Set[int]]:
    """Compute proof balls Ball(0), Ball(1), ..., Ball(max_depth)."""
    balls = [set(axioms)]
    for k in range(max_depth):
        current = balls[-1]
        frontier_candidates = set()
        for a in current:
            frontier_candidates |= derives.get(a, set())
        balls.append(current | frontier_candidates)
    return balls


def compute_frontiers(balls: List[Set[int]]) -> List[Set[int]]:
    """Compute frontiers F(0), F(1), ..., F(len-2)."""
    return [balls[k + 1] - balls[k] for k in range(len(balls) - 1)]


def depth_lower_bound(n: int, axiom_count: int, max_frontier: int) -> int:
    """Compute (n - axiom_count) // max_frontier."""
    if max_frontier <= 0:
        return 0
    return max(0, (n - axiom_count)) // max_frontier


# ============================================================
# Example 1: Linear Chain
# ============================================================
print("=" * 60)
print("Example 1: Linear Chain (worst-case expansion)")
print("=" * 60)

n = 20
axioms = {0}
derives = {i: {i + 1} for i in range(n)}

balls = compute_proof_balls(axioms, derives, n)
frontiers = compute_frontiers(balls)

print(f"  Axioms: {axioms}")
print(f"  Type size: {n + 1}")
print()
for k in range(min(10, len(balls))):
    fr = frontiers[k] if k < len(frontiers) else set()
    print(f"  Depth {k:2d}: |Ball| = {len(balls[k]):3d}, |Frontier| = {len(fr):2d}")

print(f"\n  Min frontier (first 10 steps): {min(len(f) for f in frontiers[:10])}")
print(f"  Depth lower bound for n=15: {depth_lower_bound(15, 1, 1)}")
print(f"  Actual depth to reach 15: {min(k for k, b in enumerate(balls) if 15 in b)}")

# ============================================================
# Example 2: Binary Tree (exponential expansion)
# ============================================================
print("\n" + "=" * 60)
print("Example 2: Binary Tree (exponential expansion)")
print("=" * 60)

axioms = {1}  # root
derives = {i: {2 * i, 2 * i + 1} for i in range(1, 64)}

balls = compute_proof_balls(axioms, derives, 6)
frontiers = compute_frontiers(balls)

for k in range(len(balls)):
    fr = frontiers[k] if k < len(frontiers) else set()
    print(f"  Depth {k}: |Ball| = {len(balls[k]):3d}, |Frontier| = {len(fr):2d}")

print(f"\n  Growth ratio: {[f'{len(balls[k+1])/max(1,len(balls[k])):.2f}' for k in range(len(balls)-1)]}")
print(f"  Min frontier: {min(len(f) for f in frontiers)}")
print(f"  Additive lower bound for 63 statements: {depth_lower_bound(63, 1, 32)} steps")

# ============================================================
# Example 3: Expander-like graph
# ============================================================
print("\n" + "=" * 60)
print("Example 3: Cyclic Shift Expander")
print("=" * 60)

n = 50
axioms = {0}
# Each node i derives i+1, i+3, i+7 (mod n)
derives = {i: {(i + 1) % n, (i + 3) % n, (i + 7) % n} for i in range(n)}

balls = compute_proof_balls(axioms, derives, 15)
frontiers = compute_frontiers(balls)

for k in range(len(balls)):
    fr = frontiers[k] if k < len(frontiers) else set()
    stab = " (stabilized)" if k > 0 and balls[k] == balls[k - 1] else ""
    print(f"  Depth {k:2d}: |Ball| = {len(balls[k]):3d}, |Frontier| = {len(fr):2d}{stab}")

stab_depth = next(
    (k for k in range(len(balls) - 1) if balls[k] == balls[k + 1]), None
)
print(f"\n  Stabilization depth: {stab_depth}")
print(f"  Final derivable set size: {len(balls[-1])}")

# ============================================================
# Example 4: Proof Domination
# ============================================================
print("\n" + "=" * 60)
print("Example 4: Proof Domination")
print("=" * 60)

axioms_weak = {0}
derives_weak = {i: {i + 1} for i in range(20)}

axioms_strong = {0, 1}
derives_strong = {i: {i + 1, i + 2} for i in range(20)}

balls_weak = compute_proof_balls(axioms_weak, derives_weak, 10)
balls_strong = compute_proof_balls(axioms_strong, derives_strong, 10)

print("  Weak system: 1 axiom, 1 derivation per step")
print("  Strong system: 2 axioms, 2 derivations per step")
print()
for k in range(11):
    dom = "✓" if balls_weak[k] <= balls_strong[k] else "✗"
    print(
        f"  Depth {k:2d}: |Weak| = {len(balls_weak[k]):3d}, "
        f"|Strong| = {len(balls_strong[k]):3d}, Dominated: {dom}"
    )

# ============================================================
# Example 5: Expansion Certificate Verification
# ============================================================
print("\n" + "=" * 60)
print("Example 5: Expansion Certificate")
print("=" * 60)

axioms = {0}
derives = {i: {i + 1, i + 2, i + 3} for i in range(100)}

balls = compute_proof_balls(axioms, derives, 15)
frontiers = compute_frontiers(balls)

min_fr = min(len(f) for f in frontiers[:10] if len(f) > 0)
steps = sum(1 for f in frontiers if len(f) > 0)

print(f"  Expansion certificate: steps={steps}, minFrontier={min_fr}")
print(f"  Guaranteed lower bound: |axioms| + steps * minFrontier = {1 + steps * min_fr}")
print(f"  Actual |Ball(steps)|: {len(balls[steps])}")
print(
    f"  Depth lower bound to reach 50 with f=3: "
    f"{depth_lower_bound(50, 1, 3)} steps"
)


print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


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
