import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 1, figsize=(12, 6))
ax = axes[0]
c = 1/3
for depth in range(7):
    intervals = [(0.0, 1.0)]
    for _ in range(depth):
        new = []
        for a, b in intervals:
            new.append((c*a, c*b))
            new.append((c*a + (1-c), c*b + (1-c)))
        intervals = new
    y = 6 - depth
    for a, b in intervals:
        ax.plot([a, b], [y, y], 'b-', linewidth=3)
ax.set_title('Cantor Set Construction (c=1/3)')
ax.set_xlabel('Score')
ax.set_ylabel('Depth')

ax = axes[1]
c_vals = np.linspace(0.05, 0.49, 100)
dims = np.log(2) / np.log(1/c_vals)
ax.plot(c_vals, dims, 'b-', linewidth=2)
ax.scatter([1/3], [np.log(2)/np.log(3)], color='red', s=100, zorder=5)
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5)
ax.set_title('Attractor Dimension vs Contraction Ratio')
ax.set_xlabel('c')
ax.set_ylabel('Hausdorff dimension')
ax.legend(['d(c)', 'Standard Cantor'])
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('cantor_attractor.png', dpi=150)
plt.close()