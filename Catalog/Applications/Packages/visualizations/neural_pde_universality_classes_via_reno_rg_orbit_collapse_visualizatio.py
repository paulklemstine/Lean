import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def affine_contraction_rg(c, fp):
    return lambda x: fp + c * (x - fp)

def rg_iterate(coarsen, x, n):
    orbit = [x.copy()]
    cur = x.copy()
    for _ in range(n):
        cur = coarsen(cur)
        orbit.append(cur.copy())
    return orbit

rng = np.random.RandomState(42)
dim, n_arch, n_steps = 4, 8, 40
fp = rng.randn(dim)
coarsen = affine_contraction_rg(0.6, fp)
colors = plt.cm.tab10(np.linspace(0, 1, n_arch))

fig, axes = plt.subplots(1, 3, figsize=(18, 5))
ax = axes[0]
for i in range(n_arch):
    x0 = rng.randn(dim) * 5
    orbit = rg_iterate(coarsen, x0, n_steps)
    dists = [np.linalg.norm(o - fp) for o in orbit]
    ax.semilogy(range(n_steps + 1), dists, color=colors[i], alpha=0.8, label=f'Arch {i+1}')
ax.set_xlabel('RG Step'); ax.set_ylabel('Distance to Fixed Point')
ax.set_title('Architecture Collapse (c=0.6)'); ax.legend(fontsize=7); ax.grid(True, alpha=0.3)

ax = axes[1]
fps = [np.array([2,1,0,0.]), np.array([-1,3,0,0.]), np.array([0,-2,0,0.])]
cc = ['#e74c3c','#3498db','#2ecc71']
for ci, f in enumerate(fps):
    cg = affine_contraction_rg(0.5, f)
    for _ in range(4):
        x0 = f + rng.randn(4)*3
        orb = rg_iterate(cg, x0, n_steps)
        ax.plot([o[0]+o[1] for o in orb], color=cc[ci], alpha=0.6)
ax.set_xlabel('RG Step'); ax.set_ylabel('Conservation Value')
ax.set_title('Conservation Separates Classes'); ax.grid(True, alpha=0.3)

ax = axes[2]
for br in [0.5, 0.6, 0.7, 0.8, 0.9]:
    orders = range(1, 7)
    ax.plot(list(orders), [br**p for p in orders], 'o-', label=f'base={br}')
ax.set_xlabel('Differential Order'); ax.set_ylabel('Effective Rate')
ax.set_title('Higher Order = Faster Convergence'); ax.legend(); ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_rg_collapse.png', dpi=150, bbox_inches='tight')
print('Saved viz_rg_collapse.png')