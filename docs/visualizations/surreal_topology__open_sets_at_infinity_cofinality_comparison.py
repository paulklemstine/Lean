import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: R (countable cofinality)
ax = axes[0]
ax.set_title('R: Countable Cofinality', fontsize=14, fontweight='bold')
ax.axhline(y=0, color='black', linewidth=2)
seq = [1/n for n in range(1, 16)]
for s in seq: ax.plot(s, 0, 'r^', markersize=8)
ax.plot(0, 0, 'ko', markersize=10)
ax.set_xlim(-0.1, 1.2); ax.set_ylim(-0.1, 0.1)
ax.text(0.5, -0.07, 'Sequence IS cofinal', color='green', ha='center', fontweight='bold')

# Right: Surreals (uncountable cofinality)
ax = axes[1]
ax.set_title('No: Uncountable Cofinality', fontsize=14, fontweight='bold')
ax.axhline(y=0, color='black', linewidth=2)
seq_s = [0.1/n + 0.3 for n in range(1, 16)]
for s in seq_s: ax.plot(s, 0, 'r^', markersize=8)
ax.plot(0, 0, 'ko', markersize=10)
ax.axvline(x=0.2, color='purple', linestyle='--', linewidth=2)
ax.add_patch(patches.Rectangle((0.01, -0.03), 0.19, 0.06, alpha=0.2, color='purple'))
ax.set_xlim(-0.1, 0.8); ax.set_ylim(-0.1, 0.1)
ax.text(0.35, -0.07, 'NO countable cofinal sequence', color='red', ha='center', fontweight='bold')

plt.tight_layout()
plt.savefig('cofinality_comparison.png', dpi=150)
plt.close()