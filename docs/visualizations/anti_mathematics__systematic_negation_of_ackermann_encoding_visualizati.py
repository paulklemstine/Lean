import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def ackermann_decode(n):
    members = set()
    i = 0
    while n > 0:
        if n & 1: members.add(i)
        n >>= 1; i += 1
    return members

fig, axes = plt.subplots(2, 4, figsize=(16, 8))
fig.suptitle('Ackermann Encoding: Natural Numbers as Sets', fontsize=16, fontweight='bold')

for idx, n in enumerate([0, 1, 2, 3, 5, 7, 10, 15]):
    ax = axes[idx // 4][idx % 4]
    members = ackermann_decode(n)
    bits = format(n, '04b')
    
    colors = ['#e74c3c' if i in members else '#ecf0f1' for i in range(4)]
    bars = ax.bar(range(4), [1]*4, color=colors, edgecolor='#2c3e50', linewidth=2)
    
    for i in range(4):
        ax.text(i, 0.5, str(i), ha='center', va='center', fontsize=14, fontweight='bold')
    
    ax.set_title(f'n={n} → {members if members else "∅"}', fontsize=12)
    ax.set_ylim(0, 1.2)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_xlim(-0.5, 3.5)

plt.tight_layout()
plt.savefig('ackermann_viz.png', dpi=150, bbox_inches='tight')
plt.show()
print('Saved ackermann_viz.png')