import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(12, 4))

finite_x = list(range(8))
ax.scatter(finite_x, [0]*len(finite_x), c='blue', s=60, zorder=5, label='Finite')
ax.scatter([10], [0], c='green', s=120, zorder=5, marker='D', label='aleph_0')
ax.annotate('aleph_0', (10, 0), xytext=(0, 15), textcoords='offset points', fontsize=14, ha='center', color='green', fontweight='bold')
ax.annotate('', xy=(13, 0), xytext=(11, 0), arrowprops=dict(arrowstyle='<->', color='red', lw=2))
ax.text(12, 0.12, 'NO CARDINALS HERE', ha='center', fontsize=10, color='red', fontweight='bold')
ax.scatter([14], [0], c='red', s=120, zorder=5, marker='s', label='aleph_1')
ax.annotate('aleph_1 = c (CH)', (14, 0), xytext=(0, 15), textcoords='offset points', fontsize=12, ha='center', color='red', fontweight='bold')
ax.scatter([17], [0], c='purple', s=120, zorder=5, marker='^', label='aleph_2')
ax.annotate('aleph_2', (17, 0), xytext=(0, 15), textcoords='offset points', fontsize=14, ha='center', color='purple', fontweight='bold')
ax.set_xlim(-1, 19)
ax.set_ylim(-0.2, 0.4)
ax.set_xlabel('Cardinal Scale (schematic)')
ax.set_title('The Cantor Dimension Gap')
ax.legend(loc='lower right')
ax.set_yticks([])
ax.spines['top'].set_visible(False)
ax.spines['left'].set_visible(False)
ax.spines['right'].set_visible(False)
plt.tight_layout()
plt.savefig('dimension_gap.png', dpi=150)
plt.close()