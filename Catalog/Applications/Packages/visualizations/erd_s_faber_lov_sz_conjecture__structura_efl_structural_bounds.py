import matplotlib.pyplot as plt
import numpy as np
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Structural Bounds for EFL Systems', fontsize=16, fontweight='bold')
ks = np.arange(1, 16)
ax = axes[0, 0]
ax.fill_between(ks, ks, ks**2, alpha=0.3, color='steelblue')
ax.plot(ks, ks, 'b-', linewidth=2, label='Lower (k)')
ax.plot(ks, ks**2, 'r-', linewidth=2, label='Upper (k²)')
ax.plot(ks, ks**2 - ks + 1, 'g--', linewidth=2, label='Near-pencil')
ax.set_xlabel('k'); ax.set_ylabel('|V|'); ax.set_title('Vertex Set Size'); ax.legend(fontsize=8); ax.set_yscale('log')
ax = axes[0, 1]
ax.plot(ks, ks * (ks - 1) / 2, 'r-', linewidth=2, label='Bound k(k-1)/2')
ax.fill_between(ks, 0, ks * (ks - 1) / 2, alpha=0.2, color='coral')
ax.set_xlabel('k'); ax.set_ylabel('Count'); ax.set_title('High-Degree Vertex Bound'); ax.legend(fontsize=8)
ax = axes[1, 0]
ax.plot(ks, ks**2, 'b-', linewidth=2, label='k²')
ax.plot(ks, ks * (ks - 1), 'm--', linewidth=2, label='k(k-1)')
ax.set_xlabel('k'); ax.set_ylabel('Count'); ax.set_title('Counting Invariants'); ax.legend(fontsize=8)
ax = axes[1, 1]
for k in [3, 5, 7]:
    degs = [k] + [1] * (k * (k - 1))
    ax.step(range(len(degs)), degs, linewidth=1.5, label=f'k={k}', where='mid')
ax.set_xlabel('Vertex index'); ax.set_ylabel('Degree'); ax.set_title('Degree Sequences'); ax.legend(fontsize=8)
plt.tight_layout(); plt.savefig('efl_bounds.png', dpi=150); plt.close()