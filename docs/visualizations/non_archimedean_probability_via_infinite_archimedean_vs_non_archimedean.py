import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
epsilons = [0.1, 0.05, 0.02, 0.01]
ns = np.arange(1, 201)
for eps in epsilons:
    ax1.plot(ns, ns * eps, label=f'ε = {eps}')
ax1.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Budget = 1')
ax1.set_xlabel('Number of points n')
ax1.set_ylabel('Cumulative probability n·ε')
ax1.set_title('Archimedean: Budget Always Exceeded')
ax1.legend()
ax1.set_ylim(0, 2.5)
ax1.grid(True, alpha=0.3)

ns2 = np.arange(1, 1001)
for label, a in [('ε₁', 0.3), ('ε₂', 0.2), ('ε₃', 0.1)]:
    ax2.plot(ns2, a * (1 - np.exp(-ns2/200)), label=label, linewidth=2)
ax2.axhline(y=1, color='red', linestyle='--', linewidth=2)
ax2.set_xlabel('Number of points n')
ax2.set_title('Non-Archimedean: Budget Never Exceeded')
ax2.legend()
ax2.set_ylim(0, 1.5)
ax2.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('archimedean_comparison.png', dpi=150)
