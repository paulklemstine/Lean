import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

step = {0: 1, 1: 2, 2: 0, 3: 4, 4: 3, 5: 5}
n = len(step)

# Layout: circle
angles = [2 * np.pi * i / n - np.pi/2 for i in range(n)]
pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}

fig, ax = plt.subplots(figsize=(7, 7))
for i, j in step.items():
    x0, y0 = pos[i]
    x1, y1 = pos[j]
    if i == j:
        ax.annotate('', xy=(x0, y0+0.15), xytext=(x0+0.1, y0+0.2),
                     arrowprops=dict(arrowstyle='->', color='darkred', lw=2))
    else:
        dx, dy = x1-x0, y1-y0
        ax.annotate('', xy=(x1-0.08*dx/max(abs(dx)+abs(dy),1e-9), y1-0.08*dy/max(abs(dx)+abs(dy),1e-9)),
                     xytext=(x0, y0),
                     arrowprops=dict(arrowstyle='->', color='steelblue', lw=2))

for i, (x, y) in pos.items():
    ax.plot(x, y, 'o', markersize=30, color='gold', markeredgecolor='black', markeredgewidth=2)
    ax.text(x, y, str(i), ha='center', va='center', fontsize=16, fontweight='bold')

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.7)
ax.set_aspect('equal')
ax.set_title('Transition Graph: 0→1→2→0, 3↔4, 5→5', fontsize=14)
ax.axis('off')
plt.tight_layout()
plt.savefig('transition_graph.png', dpi=150)
print('Saved transition_graph.png')