import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

n = 4
adj = {v: set(range(n)) - {v} for v in range(n)}

def chip_fire(D, v):
    r = list(D); r[v] -= len(adj[v])
    for w in adj[v]: r[w] += 1
    return tuple(r)

configs = [(4,0,0,0), (3,1,0,0), (2,2,0,0), (2,1,1,0), (1,1,1,1)]
fig, axes = plt.subplots(len(configs), 1, figsize=(14, 3*len(configs)))
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
for idx, init in enumerate(configs):
    ax = axes[idx]; history = [list(init)]; current = list(init)
    for _ in range(12):
        fired = False
        for v in range(n):
            if current[v] >= len(adj[v]):
                current = list(chip_fire(tuple(current), v))
                history.append(list(current)); fired = True; break
        if not fired: break
    data = np.array(history); x = np.arange(len(history))
    for v in range(n):
        ax.plot(x, data[:, v], 'o-', color=colors[v], label=f'v_{v}', markersize=6, linewidth=2)
    ax.set_ylabel('Chips'); ax.set_title(f'Initial: {list(init)}')
    ax.legend(loc='upper right', ncol=4); ax.grid(True, alpha=0.3)
axes[-1].set_xlabel('Step')
fig.suptitle('Chip-Firing on K_4', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('chipfiring_dynamics.png', dpi=150, bbox_inches='tight')
plt.close()
print('Saved chipfiring_dynamics.png')