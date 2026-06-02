import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def suspicion_fn(r):
    return r**2 * (1 - r)

def valley_model(alpha, r):
    return r - alpha * suspicion_fn(r)

fig, ax = plt.subplots(figsize=(10, 6))
r = np.linspace(0, 1, 1000)
for alpha, c in [(0,'#2196F3'), (2,'#4CAF50'), (4,'#FF9800'), (6,'#f44336'), (10,'#9C27B0'), (20,'#795548')]:
    ax.plot(r, valley_model(alpha, r), color=c, linewidth=2, label=f'α={alpha}')
ax.axhline(0, color='gray', alpha=0.5)
ax.set_xlabel('Rigor Level r')
ax.set_ylabel('Trust U(r)')
ax.set_title('The Mathematical Uncanny Valley')
ax.legend()
ax.grid(True, alpha=0.3)
fig.savefig('valley_comparison.png', dpi=150)
print('Saved valley_comparison.png')