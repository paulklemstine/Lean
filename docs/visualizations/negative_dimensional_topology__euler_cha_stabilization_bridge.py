import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(10, 6))
start_dims = [-10, -7, -5, -3, -1]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(start_dims)))
for i, sd in enumerate(start_dims):
    steps = max(0, 1 - sd)
    dims = [sd + n for n in range(steps + 3)]
    ax.plot(range(len(dims)), dims, 'o-', color=colors[i], label=f'dim₀ = {sd}', markersize=6)
ax.axhline(y=0, color='red', linestyle='--', linewidth=2, alpha=0.7)
ax.fill_between(range(15), -12, 0, alpha=0.1, color='red')
ax.fill_between(range(15), 0, 5, alpha=0.1, color='green')
ax.set_xlabel('Suspensions')
ax.set_ylabel('Dimension')
ax.set_title('Stabilization: Suspension Lifts to Positive Dimension')
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('stabilization.png', dpi=150)
plt.close()