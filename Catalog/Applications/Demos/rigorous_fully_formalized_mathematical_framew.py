#!/usr/bin/env python3
"""
Multi-Objective Refinement Systems — Demonstration

Numerical examples illustrating the main theorems:
1. Pareto dominance and chain bounds
2. Componentwise convergence of a Pareto optimizer
3. Collapse information loss
4. Weighted analysis
5. Product construction
"""

from typing import Tuple, List
import random

# Inline all needed functions to keep this self-contained
ComplexityVector = Tuple[int, ...]


def pareto_dominates(x: ComplexityVector, y: ComplexityVector) -> bool:
    return all(xi <= yi for xi, yi in zip(x, y)) and any(xi < yi for xi, yi in zip(x, y))


def total_complexity(x: ComplexityVector) -> int:
    return sum(x)


def weighted_total(x: ComplexityVector, weights: Tuple[int, ...]) -> int:
    return sum(w * c for w, c in zip(weights, x))


def compute_pareto_frontier(points: List[ComplexityVector]) -> List[ComplexityVector]:
    return [p for p in points if not any(pareto_dominates(q, p) for q in points)]


def main():
    print("=" * 70)
    print("MULTI-OBJECTIVE REFINEMENT SYSTEMS — DEMONSTRATION")
    print("=" * 70)

    # --- Example 1: Pareto Dominance ---
    print("\n1. PARETO DOMINANCE")
    print("-" * 40)
    a, b, c = (2, 3, 1), (3, 4, 2), (1, 5, 0)
    print(f"  a = {a}, b = {b}, c = {c}")
    print(f"  a dominates b? {pareto_dominates(a, b)}  (yes: 2≤3, 3≤4, 1≤2, all ≤ and some <)")
    print(f"  a dominates c? {pareto_dominates(a, c)}  (no: a[1]=3 but c[1]=5, so a[1] > c[1])")
    print(f"  c dominates a? {pareto_dominates(c, a)}  (no: c[1]=5 > a[1]=3)")
    print(f"  → a and c are Pareto-INCOMPARABLE")

    # --- Example 2: Chain Length Bound ---
    print("\n2. CHAIN LENGTH BOUND")
    print("-" * 40)
    chain = [(5, 4, 3), (4, 4, 3), (4, 3, 3), (4, 3, 2), (3, 3, 2), (3, 2, 2), (3, 2, 1)]
    print(f"  Chain: {' → '.join(str(x) for x in chain)}")
    chain_len = len(chain) - 1
    init_total = total_complexity(chain[0])
    print(f"  Chain length: {chain_len}")
    print(f"  Total complexity of initial element: {init_total}")
    print(f"  Theorem: chain_length ≤ total_complexity → {chain_len} ≤ {init_total} ✓")
    valid = all(pareto_dominates(chain[i + 1], chain[i]) for i in range(len(chain) - 1))
    print(f"  Valid Pareto chain? {valid}")

    # --- Example 3: Componentwise Convergence ---
    print("\n3. COMPONENTWISE CONVERGENCE")
    print("-" * 40)

    def optimizer_step(x: ComplexityVector) -> ComplexityVector:
        """Reduce the largest component by 1, leave others unchanged."""
        lst = list(x)
        if max(lst) > 0:
            idx = lst.index(max(lst))
            lst[idx] -= 1
        return tuple(lst)

    x0 = (5, 3, 4)
    orbit = [x0]
    current = x0
    for _ in range(20):
        nxt = optimizer_step(current)
        if nxt == current:
            break
        orbit.append(nxt)
        current = nxt

    print(f"  Starting point: {x0}")
    print(f"  Optimizer: reduce largest component by 1")
    print(f"  Orbit:")
    for i, pt in enumerate(orbit):
        print(f"    step {i}: {pt}  total={total_complexity(pt)}")
    print(f"  Converged after {len(orbit) - 1} steps to {orbit[-1]}")
    print(f"  All components stable? {orbit[-1] == optimizer_step(orbit[-1])} ✓")

    # --- Example 4: Collapse Information Loss ---
    print("\n4. COLLAPSE INFORMATION LOSS")
    print("-" * 40)
    points = [(2, 0), (0, 3), (1, 1)]
    print(f"  Points: {points}")
    print(f"  Totals: {[total_complexity(p) for p in points]}")
    x, y = (2, 0), (0, 3)
    print(f"\n  x = {x} (total {total_complexity(x)})")
    print(f"  y = {y} (total {total_complexity(y)})")
    print(f"  total(x) < total(y)? {total_complexity(x) < total_complexity(y)} → collapsed says x dominates y")
    print(f"  x Pareto-dominates y? {pareto_dominates(x, y)} → x[0]=2 > y[0]=0, FAILS!")
    print(f"  → Collapse creates FALSE ranking between incomparable elements")

    # --- Example 5: Pareto Frontier ---
    print("\n5. PARETO FRONTIER (ANTICHAIN)")
    print("-" * 40)
    random.seed(42)
    points = [(random.randint(0, 10), random.randint(0, 10)) for _ in range(20)]
    frontier = compute_pareto_frontier(points)
    print(f"  20 random 2D points, frontier has {len(frontier)} points:")
    for p in sorted(frontier):
        print(f"    {p}")
    # Verify antichain property
    is_antichain = all(
        not pareto_dominates(a, b)
        for a in frontier
        for b in frontier
        if a != b
    )
    print(f"  Antichain property verified? {is_antichain} ✓")

    # --- Example 6: Weighted Analysis ---
    print("\n6. WEIGHTED CHAIN BOUND")
    print("-" * 40)
    chain = [(3, 5), (2, 5), (2, 4), (1, 4), (1, 3), (0, 3), (0, 2), (0, 1), (0, 0)]
    w1 = (1, 1)
    w2 = (2, 1)
    w3 = (1, 3)
    chain_len = len(chain) - 1
    print(f"  Chain of length {chain_len}: {chain[0]} → ... → {chain[-1]}")
    print(f"  Unweighted bound (w=(1,1)): {weighted_total(chain[0], w1)} ≥ {chain_len} ✓")
    print(f"  Weighted bound   (w=(2,1)): {weighted_total(chain[0], w2)} ≥ {chain_len} ✓")
    print(f"  Weighted bound   (w=(1,3)): {weighted_total(chain[0], w3)} ≥ {chain_len} ✓")

    # --- Example 7: Product Construction ---
    print("\n7. PRODUCT CONSTRUCTION")
    print("-" * 40)
    x1 = (3, 2)  # System 1: 2 objectives
    x2 = (4,)    # System 2: 1 objective
    product = x1 + x2  # Combined: 3 objectives
    print(f"  System 1: x1 = {x1}, total = {total_complexity(x1)}")
    print(f"  System 2: x2 = {x2}, total = {total_complexity(x2)}")
    print(f"  Product:  (x1, x2) = {product}, total = {total_complexity(product)}")
    print(f"  Additivity: {total_complexity(x1)} + {total_complexity(x2)} = {total_complexity(product)} ✓")

    # --- Example 8: Strict Decrease Count ---
    print("\n8. STRICT DECREASE COUNT")
    print("-" * 40)
    seq = [10, 10, 9, 9, 9, 7, 7, 5, 5, 5, 5, 3, 3, 3, 2, 2, 1, 1, 1, 1, 0, 0]
    strict_decreases = sum(1 for i in range(len(seq) - 1) if seq[i + 1] < seq[i])
    print(f"  Non-increasing sequence: {seq[:10]}...")
    print(f"  Initial value: {seq[0]}")
    print(f"  Number of strict decreases: {strict_decreases}")
    print(f"  Theorem: strict_decreases ≤ f(0) → {strict_decreases} ≤ {seq[0]} ✓")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Collapse information loss — comparing Pareto order vs total order."""
import matplotlib.pyplot as plt
import numpy as np
import random

def pareto_dominates(x, y):
    return all(xi <= yi for xi, yi in zip(x, y)) and any(xi < yi for xi, yi in zip(x, y))

random.seed(123)
points = [(random.randint(0, 10), random.randint(0, 10)) for _ in range(30)]

# Find pairs where total order disagrees with Pareto order
false_rankings = []
true_rankings = []
for i, x in enumerate(points):
    for j, y in enumerate(points):
        if i >= j:
            continue
        tx, ty = sum(x), sum(y)
        if tx < ty:
            if pareto_dominates(x, y):
                true_rankings.append((x, y))
            else:
                false_rankings.append((x, y))
        elif ty < tx:
            if pareto_dominates(y, x):
                true_rankings.append((y, x))
            else:
                false_rankings.append((y, x))

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: show some true rankings
ax = axes[0]
ax.set_title('Collapse PRESERVES Dominance\n(Pareto agrees with total order)', fontsize=13, color='green')
for x, y in true_rankings[:5]:
    ax.annotate('', xy=x, xytext=y,
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax.scatter(*x, c='green', s=80, zorder=3, edgecolors='darkgreen')
    ax.scatter(*y, c='lightgreen', s=80, zorder=3, edgecolors='green')
    ax.annotate(f't={sum(x)}', xy=x, xytext=(x[0]+0.3, x[1]+0.3), fontsize=8)
    ax.annotate(f't={sum(y)}', xy=y, xytext=(y[0]+0.3, y[1]+0.3), fontsize=8)
ax.set_xlabel('Objective 1')
ax.set_ylabel('Objective 2')
ax.grid(True, alpha=0.3)
ax.set_xlim(-1, 12)
ax.set_ylim(-1, 12)

# Right: show false rankings
ax = axes[1]
ax.set_title('Collapse CREATES False Rankings\n(Total order disagrees with Pareto)', fontsize=13, color='red')
for x, y in false_rankings[:5]:
    ax.annotate('', xy=x, xytext=y,
                arrowprops=dict(arrowstyle='->', color='red', lw=2, linestyle='dashed'))
    ax.scatter(*x, c='red', s=80, zorder=3, edgecolors='darkred')
    ax.scatter(*y, c='lightsalmon', s=80, zorder=3, edgecolors='red')
    ax.annotate(f't={sum(x)}', xy=x, xytext=(x[0]+0.3, x[1]+0.3), fontsize=8)
    ax.annotate(f't={sum(y)}', xy=y, xytext=(y[0]+0.3, y[1]+0.3), fontsize=8)
ax.set_xlabel('Objective 1')
ax.set_ylabel('Objective 2')
ax.grid(True, alpha=0.3)
ax.set_xlim(-1, 12)
ax.set_ylim(-1, 12)

fig.suptitle('The Collapse Information-Loss Theorem', fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('collapse_info_loss.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved collapse_info_loss.png")


#!/usr/bin/env python3
"""Visualization: Componentwise convergence of a Pareto optimizer."""
import matplotlib.pyplot as plt
import numpy as np

def optimizer_step(x):
    """Reduce the largest component by 1."""
    lst = list(x)
    if max(lst) > 0:
        idx = lst.index(max(lst))
        lst[idx] -= 1
    return tuple(lst)

# Run optimizer
x0 = (8, 5, 6)
orbit = [x0]
current = x0
for _ in range(30):
    nxt = optimizer_step(current)
    if nxt == current:
        break
    orbit.append(nxt)
    current = nxt

steps = list(range(len(orbit)))
c1 = [x[0] for x in orbit]
c2 = [x[1] for x in orbit]
c3 = [x[2] for x in orbit]
total = [sum(x) for x in orbit]

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), sharex=True)

# Top: individual components
ax1.plot(steps, c1, 'o-', color='#e74c3c', label='Objective 1', markersize=5)
ax1.plot(steps, c2, 's-', color='#3498db', label='Objective 2', markersize=5)
ax1.plot(steps, c3, '^-', color='#2ecc71', label='Objective 3', markersize=5)
ax1.set_ylabel('Component Value', fontsize=12)
ax1.set_title('Componentwise Convergence: All Components Stabilize Simultaneously', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='gray', linestyle=':', alpha=0.5)

# Bottom: total complexity
ax2.plot(steps, total, 'D-', color='#9b59b6', label='Total Complexity', markersize=6, linewidth=2)
ax2.fill_between(steps, total, alpha=0.1, color='#9b59b6')
ax2.set_xlabel('Optimization Step', fontsize=12)
ax2.set_ylabel('Total Complexity', fontsize=12)
ax2.set_title('Total Complexity: Strictly Decreasing, Bounds Chain Length', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# Annotate
ax2.annotate(f'Initial total = {total[0]}', xy=(0, total[0]),
             xytext=(3, total[0] - 1), fontsize=10,
             arrowprops=dict(arrowstyle='->', color='gray'))
ax2.annotate(f'Final total = {total[-1]}', xy=(steps[-1], total[-1]),
             xytext=(steps[-1] - 4, total[-1] + 3), fontsize=10,
             arrowprops=dict(arrowstyle='->', color='gray'))

plt.tight_layout()
plt.savefig('convergence.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved convergence.png")


#!/usr/bin/env python3
"""Visualization: 2D Pareto Frontier with dominated region."""
import matplotlib.pyplot as plt
import numpy as np
import random

def pareto_dominates(x, y):
    return all(xi <= yi for xi, yi in zip(x, y)) and any(xi < yi for xi, yi in zip(x, y))

def compute_pareto_frontier(points):
    return [p for p in points if not any(pareto_dominates(q, p) for q in points)]

random.seed(42)
np.random.seed(42)
points = [(random.randint(0, 20), random.randint(0, 20)) for _ in range(50)]
frontier = compute_pareto_frontier(points)
non_frontier = [p for p in points if p not in frontier]

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# Plot non-frontier points
if non_frontier:
    ax.scatter([p[0] for p in non_frontier], [p[1] for p in non_frontier],
               c='lightgray', s=60, zorder=2, label='Dominated', edgecolors='gray')

# Plot frontier points
frontier_sorted = sorted(frontier, key=lambda p: p[0])
ax.scatter([p[0] for p in frontier_sorted], [p[1] for p in frontier_sorted],
           c='red', s=120, zorder=3, label='Pareto Frontier', edgecolors='darkred', linewidths=1.5)

# Draw staircase showing the frontier boundary
if frontier_sorted:
    xs = [p[0] for p in frontier_sorted]
    ys = [p[1] for p in frontier_sorted]
    stair_x = [0]
    stair_y = [max(ys) + 2]
    for x, y in frontier_sorted:
        stair_x.extend([x, x])
        stair_y.extend([stair_y[-1], y])
    stair_x.append(max(xs) + 2)
    stair_y.append(stair_y[-1])
    ax.plot(stair_x, stair_y, 'r--', alpha=0.5, linewidth=1.5)
    ax.fill_between(stair_x, stair_y, max(ys) + 3, alpha=0.05, color='red')

ax.set_xlabel('Objective 1 (complexity)', fontsize=12)
ax.set_ylabel('Objective 2 (complexity)', fontsize=12)
ax.set_title('Pareto Frontier: No Frontier Point Dominates Another (Antichain)', fontsize=14)
ax.legend(fontsize=11)
ax.set_xlim(-1, 22)
ax.set_ylim(-1, 22)
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

# Annotate
ax.annotate('Dominated region\n(above frontier)', xy=(15, 18), fontsize=10,
            ha='center', color='gray', style='italic')
ax.annotate('Pareto frontier\n(antichain)', xy=(frontier_sorted[0][0] + 1, frontier_sorted[0][1] - 2),
            fontsize=10, ha='center', color='red', fontweight='bold')

plt.tight_layout()
plt.savefig('pareto_frontier.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved pareto_frontier.png")
