#!/usr/bin/env python3
"""
Demo 2: Pythagorean Quantum Error-Correcting Codes (Direction D1)

The Berggren tree generates ALL primitive Pythagorean triples from (3,4,5).
Each triple (a,b,c) with a²+b²=c² defines quantum code parameters:
  - Code rate R = a/c (fraction of logical qubits)
  - Error fraction E = b/c (fraction of correctable errors)
  - Constraint: R² + E² = 1 (they live on the unit circle!)

This demo enumerates the Berggren tree, plots the rate-error tradeoff,
and shows the tree structure with quantum gate interpretations.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from collections import deque
import matplotlib
matplotlib.use('Agg')

def berggren_children(a, b, c):
    """Generate three children of (a,b,c) in the Berggren tree."""
    return [
        (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c),   # M₁
        (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c),   # M₂
        (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c), # M₃
    ]

def enumerate_berggren_tree(max_depth=8):
    """BFS enumeration of the Berggren tree up to given depth."""
    root = (3, 4, 5)
    triples = [root]
    queue = deque([(root, 0)])

    while queue:
        triple, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for child in berggren_children(*triple):
            # Take absolute values (some branches produce negative entries)
            child = tuple(abs(x) for x in child)
            triples.append(child)
            queue.append((child, depth + 1))

    return triples

def verify_pythagorean(triples):
    """Verify all triples satisfy a² + b² = c²."""
    for a, b, c in triples:
        assert a**2 + b**2 == c**2, f"Failed: {a}² + {b}² ≠ {c}²"
    return True

# Generate triples
triples = enumerate_berggren_tree(max_depth=7)
verify_pythagorean(triples)
print(f"Generated {len(triples)} Pythagorean triples")

# Compute rates and error fractions
rates = np.array([a/c for a, b, c in triples])
errors = np.array([b/c for a, b, c in triples])
hypotenuses = np.array([c for _, _, c in triples])

# ─── Figure 1: Rate-Error Tradeoff on Unit Circle ───
fig = plt.figure(figsize=(16, 14))
gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

ax1 = fig.add_subplot(gs[0, 0])
theta = np.linspace(0, np.pi/2, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2, alpha=0.3,
         label='Unit circle (R² + E² = 1)')

scatter = ax1.scatter(rates, errors, c=np.log10(hypotenuses), cmap='viridis',
                      s=15, alpha=0.7, edgecolors='none')
plt.colorbar(scatter, ax=ax1, label='log₁₀(hypotenuse c)')

# Highlight root triple
ax1.scatter([3/5], [4/5], c='red', s=100, zorder=5, marker='*',
            edgecolors='black', linewidth=1, label='Root: (3,4,5)')

ax1.set_xlabel('Code Rate R = a/c', fontsize=12)
ax1.set_ylabel('Error Fraction E = b/c', fontsize=12)
ax1.set_title('Pythagorean Quantum Code Parameters\n(R² + E² = 1 on unit circle)',
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=10, loc='lower left')
ax1.set_xlim(0, 1)
ax1.set_ylim(0, 1)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# ─── Figure 2: Rate Distribution ───
ax2 = fig.add_subplot(gs[0, 1])
ax2.hist(rates, bins=50, color='#2196F3', alpha=0.7, edgecolor='white',
         density=True, linewidth=0.5)
ax2.set_xlabel('Code Rate R = a/c', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Distribution of Code Rates\nin Berggren Tree', fontsize=13, fontweight='bold')
ax2.axvline(x=np.mean(rates), color='red', linestyle='--',
            label=f'Mean rate = {np.mean(rates):.3f}')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# ─── Figure 3: Hypotenuse Growth (Tree Depth) ───
ax3 = fig.add_subplot(gs[1, 0])

# Compute triples by depth
depth_triples = {}
queue = deque([((3, 4, 5), 0)])
depth_triples[0] = [(3, 4, 5)]
visited = {(3, 4, 5)}

while queue:
    triple, depth = queue.popleft()
    if depth >= 7:
        continue
    for child in berggren_children(*triple):
        child = tuple(abs(x) for x in child)
        if child not in visited:
            visited.add(child)
            depth_triples.setdefault(depth + 1, []).append(child)
            queue.append((child, depth + 1))

depths = sorted(depth_triples.keys())
mean_c = [np.mean([c for _, _, c in depth_triples[d]]) for d in depths]
max_c = [np.max([c for _, _, c in depth_triples[d]]) for d in depths]
min_c = [np.min([c for _, _, c in depth_triples[d]]) for d in depths]

ax3.semilogy(depths, mean_c, 'o-', color='#2196F3', label='Mean c', linewidth=2)
ax3.fill_between(depths, min_c, max_c, alpha=0.2, color='#2196F3')
ax3.semilogy(depths, [5 * 3**d for d in depths], '--', color='#E91E63',
             label='5·3^d (exponential)', linewidth=1.5)
ax3.set_xlabel('Tree Depth', fontsize=12)
ax3.set_ylabel('Hypotenuse c', fontsize=12)
ax3.set_title('Berggren Tree: Hypotenuse Growth', fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

# ─── Figure 4: Pythagorean Angle Distribution ───
ax4 = fig.add_subplot(gs[1, 1])
angles = np.degrees(np.arctan2(np.array([b for _, b, _ in triples]),
                                np.array([a for a, _, _ in triples])))
ax4.hist(angles, bins=60, color='#4CAF50', alpha=0.7, edgecolor='white',
         density=True, linewidth=0.5)
ax4.set_xlabel('Angle θ = arctan(b/a) [degrees]', fontsize=12)
ax4.set_ylabel('Density', fontsize=12)
ax4.set_title('Angular Distribution of\nPythagorean Triples', fontsize=13, fontweight='bold')
ax4.axvline(x=45, color='red', linestyle='--', alpha=0.5, label='θ = 45° (a = b)')
ax4.legend(fontsize=11)
ax4.grid(True, alpha=0.3)

fig.suptitle('Direction D1: Pythagorean Quantum Error-Correcting Codes',
             fontsize=15, fontweight='bold', y=0.98)
plt.savefig('/workspace/request-project/Research/demos/fig3_berggren_quantum_codes.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Figure 3 saved: fig3_berggren_quantum_codes.png")

# ─── Figure 5: Berggren Tree Visualization (first 4 levels) ───
fig2, ax = plt.subplots(1, 1, figsize=(14, 8))

def draw_tree(ax, triple, depth, x, y, dx, max_depth=4):
    a, b, c = triple
    color = plt.cm.viridis(depth / max_depth)
    ax.plot(x, y, 'o', color=color, markersize=max(20 - 3*depth, 6),
            zorder=5, markeredgecolor='black', markeredgewidth=0.5)
    ax.text(x, y, f'({a},{b},{c})', fontsize=max(8 - depth, 4),
            ha='center', va='center', zorder=6)

    if depth >= max_depth:
        return

    children = berggren_children(a, b, c)
    positions = [-1, 0, 1]
    for child, pos in zip(children, positions):
        child = tuple(abs(x_) for x_ in child)
        cx = x + pos * dx
        cy = y - 1.5
        ax.plot([x, cx], [y - 0.3, cy + 0.3], '-', color='gray',
                linewidth=1, alpha=0.5, zorder=1)
        draw_tree(ax, child, depth + 1, cx, cy, dx * 0.35, max_depth)

draw_tree(ax, (3, 4, 5), 0, 0, 6, 5.0, max_depth=3)
ax.set_xlim(-8, 8)
ax.set_ylim(-2, 7)
ax.set_title('Berggren Tree: First 4 Levels\n(a,b,c) where a² + b² = c²',
             fontsize=14, fontweight='bold')
ax.axis('off')
plt.tight_layout()
plt.savefig('/workspace/request-project/Research/demos/fig4_berggren_tree.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Figure 4 saved: fig4_berggren_tree.png")
