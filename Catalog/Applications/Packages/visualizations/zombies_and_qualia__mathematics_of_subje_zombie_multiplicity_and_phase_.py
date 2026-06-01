import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Zombie count
ax = axes[0]
ns = np.arange(1, 12)
for k in [2, 3, 5]:
    ax.semilogy(ns, [k**n for n in ns], 'o-', label=f'{k} qualia values')
ax.set_xlabel('States (n)')
ax.set_ylabel('Zombie Variants (k^n)')
ax.set_title('Zombie Multiplicity')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Phase transition
ax = axes[1]
ns = np.arange(0, 20)
complexities = [n * math.log(n + 1) for n in ns]
threshold = 8.0
colors = ['#e74c3c' if c <= threshold else '#2ecc71' for c in complexities]
ax.bar(ns, complexities, color=colors, alpha=0.7)
ax.axhline(y=threshold, color='black', linestyle='--', linewidth=2)
ax.set_xlabel('System Size (n)')
ax.set_ylabel('Complexity')
ax.set_title('Phase Transition')
ax.grid(True, alpha=0.3)

# Panel 3: Complexity bounds
ax = axes[2]
ns = np.arange(1, 15)
ax.fill_between(ns, 1, ns, alpha=0.3, color='blue')
ax.plot(ns, ns, 'b-', linewidth=2, label='Max')
ax.plot(ns, np.ones_like(ns), 'r--', linewidth=2, label='Min (zombie)')
ax.set_xlabel('States (n)')
ax.set_ylabel('Qualia Complexity')
ax.set_title('Complexity Bounds')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('zombie_visualization.png', dpi=150)
print('Saved zombie_visualization.png')