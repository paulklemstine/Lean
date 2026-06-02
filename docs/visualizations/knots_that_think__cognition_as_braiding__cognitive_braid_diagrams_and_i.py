import matplotlib.pyplot as plt
import numpy as np
import math

def draw_braid(ax, crossings, title, n_strands=3):
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlim(-0.5, max(len(crossings), 1) + 0.5)
    ax.set_ylim(-0.5, n_strands - 0.5)
    ax.invert_yaxis()
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    for step in range(len(crossings)):
        idx, pos = crossings[step]
        c = '#27ae60' if pos else '#c0392b'
        ax.annotate('', xy=(step+0.5, idx+1), xytext=(step+0.5, idx),
                    arrowprops=dict(arrowstyle='->', color=c, lw=2))
    ax.set_xlabel('Time')
    ax.set_ylabel('Brain Region')
    ax.grid(True, alpha=0.2)

fig, axes = plt.subplots(1, 3, figsize=(15, 4))
draw_braid(axes[0], [(0, True)], 'Linear (w=1)')
draw_braid(axes[1], [(0,True),(1,True),(0,True),(1,True),(0,True),(1,True)], 'Trefoil (w=6)')
draw_braid(axes[2], [(0,True),(1,False),(0,True),(1,False)], 'Fig-8 (w=0)')
plt.tight_layout()
plt.savefig('cognitive_braids.png', dpi=150)
plt.close()

names = ['Trivial', 'Linear', 'Trefoil', 'Fig-8']
cn = [0, 1, 6, 4]
wr = [0, 1, 6, 0]
ent = [0, math.log(2), 6*math.log(2), 4*math.log(2)]
colors = ['#95a5a6', '#3498db', '#e74c3c', '#f39c12']
fig, ax = plt.subplots(1, 3, figsize=(14, 4))
ax[0].bar(names, cn, color=colors); ax[0].set_title('Crossings')
ax[1].bar(names, wr, color=colors); ax[1].set_title('Writhe')
ax[2].bar(names, ent, color=colors); ax[2].set_title('Entropy')
plt.tight_layout()
plt.savefig('invariants.png', dpi=150)
plt.close()
print('Saved cognitive_braids.png and invariants.png')