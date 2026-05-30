"""
Visualization: DFAO State Graphs and Decidability

Shows the state transition graphs of several DFAOs, with reachable states
highlighted to illustrate the decidability algorithm.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import deque


def dfao_reachable(transition, initial, n_states, k):
    """Compute reachable states via BFS."""
    visited = {initial}
    queue = deque([initial])
    while queue:
        s = queue.popleft()
        for d in range(k):
            t = transition.get((s, d), 0)
            if t not in visited:
                visited.add(t)
                queue.append(t)
    return visited


fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Decidability via State Reachability in DFAOs', 
             fontsize=16, fontweight='bold')

# Example 1: Thue-Morse DFAO (all states reachable)
ax = axes[0]
ax.set_title('Thue-Morse DFAO\n(all states reachable)', fontsize=12)
ax.set_xlim(-2, 2)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.axis('off')

# Draw states
for i, (x, y, label, out) in enumerate([(-.8, 0, '0', 't=0'), (0.8, 0, '1', 't=1')]):
    color = '#4CAF50'  # all reachable
    circle = plt.Circle((x, y), 0.4, fill=True, facecolor=color, edgecolor='black', linewidth=2)
    ax.add_patch(circle)
    ax.text(x, y+0.05, label, ha='center', va='center', fontsize=14, fontweight='bold')
    ax.text(x, y-0.15, out, ha='center', va='center', fontsize=9, color='white')

# Draw transitions
ax.annotate('', xy=(0.35, 0.25), xytext=(-0.35, 0.25),
            arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2))
ax.text(0, 0.45, 'digit 1', ha='center', fontsize=9, color='#2196F3')

ax.annotate('', xy=(-0.35, -0.25), xytext=(0.35, -0.25),
            arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2))
ax.text(0, -0.45, 'digit 1', ha='center', fontsize=9, color='#2196F3')

# Self-loops for digit 0
ax.annotate('', xy=(-1.15, 0.3), xytext=(-1.15, -0.3),
            arrowprops=dict(arrowstyle='->', color='#FF9800', lw=2, 
                          connectionstyle='arc3,rad=-0.8'))
ax.text(-1.6, 0, '0', ha='center', fontsize=9, color='#FF9800')

ax.annotate('', xy=(1.15, -0.3), xytext=(1.15, 0.3),
            arrowprops=dict(arrowstyle='->', color='#FF9800', lw=2,
                          connectionstyle='arc3,rad=-0.8'))
ax.text(1.6, 0, '0', ha='center', fontsize=9, color='#FF9800')

ax.text(0, -1.2, '✓ Value 0 appears (state 0 reachable)\n✓ Value 1 appears (state 1 reachable)',
        ha='center', fontsize=9, style='italic')

# Example 2: Partially reachable DFAO
ax = axes[1]
ax.set_title('Partial Reachability\n(state 2 unreachable)', fontsize=12)
ax.set_xlim(-2, 2)
ax.set_ylim(-2, 1.5)
ax.set_aspect('equal')
ax.axis('off')

positions = [(-0.8, 0.5), (0.8, 0.5), (0, -1)]
labels = ['0', '1', '2']
outputs = ['out=A', 'out=B', 'out=C']
reachable = {0, 1}

for i, ((x, y), label, out) in enumerate(zip(positions, labels, outputs)):
    color = '#4CAF50' if i in reachable else '#F44336'
    alpha = 1.0 if i in reachable else 0.4
    circle = plt.Circle((x, y), 0.35, fill=True, facecolor=color, 
                        edgecolor='black', linewidth=2, alpha=alpha)
    ax.add_patch(circle)
    ax.text(x, y+0.05, label, ha='center', va='center', fontsize=14, 
           fontweight='bold', alpha=alpha)
    ax.text(x, y-0.13, out, ha='center', va='center', fontsize=9, 
           color='white', alpha=alpha)

ax.annotate('', xy=(0.4, 0.55), xytext=(-0.4, 0.55),
            arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2))
ax.annotate('', xy=(-0.4, 0.45), xytext=(0.4, 0.45),
            arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2))

ax.text(0, -1.7, '✓ A appears  ✓ B appears  ✗ C never appears\n'
        'Decision: O(states × alphabet) time',
        ha='center', fontsize=9, style='italic')

# Example 3: Comparison table
ax = axes[2]
ax.set_title('Decidability Comparison', fontsize=12)
ax.axis('off')

table_data = [
    ['Sequence Class', 'Zero Problem', 'Complexity'],
    ['k-Automatic', 'Decidable ✓', 'O(n·k)'],
    ['k-Uniform Morphic', 'Decidable ✓', 'O(n·k)'],
    ['General Morphic', 'Open ?', '?'],
    ['Computable', 'Undecidable ✗', 'N/A'],
    ['Arbitrary', 'Undecidable ✗', 'N/A'],
]

colors = [['#E3F2FD'] * 3,
          ['#C8E6C9'] * 3,
          ['#C8E6C9'] * 3,
          ['#FFF9C4'] * 3,
          ['#FFCDD2'] * 3,
          ['#FFCDD2'] * 3]

table = ax.table(cellText=table_data, cellColours=colors,
                loc='center', cellLoc='center')
table.auto_set_font_size(False)
table.set_fontsize(10)
table.scale(1, 1.8)

for (row, col), cell in table.get_celld().items():
    if row == 0:
        cell.set_text_props(fontweight='bold')
    cell.set_edgecolor('gray')

plt.tight_layout()
plt.savefig('viz_decidability.png', dpi=150, bbox_inches='tight')
print("Saved viz_decidability.png")
