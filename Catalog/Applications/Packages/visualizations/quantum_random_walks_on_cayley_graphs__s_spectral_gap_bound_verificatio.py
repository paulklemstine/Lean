import matplotlib.pyplot as plt
import numpy as np

ns = list(range(3, 101))
lower_bounds = [2.0/n**2 for n in ns]
exact_gaps = [1.0 - np.cos(2*np.pi/n) for n in ns]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

ax1.semilogy(ns, exact_gaps, 'b-', linewidth=2, label=r'$1 - \cos(2\pi/n)$ (exact)')
ax1.semilogy(ns, lower_bounds, 'r--', linewidth=2, label=r'$2/n^2$ (lower bound)')
ax1.set_xlabel('n', fontsize=14)
ax1.set_ylabel('Spectral gap', fontsize=14)
ax1.set_title('Spectral Gap of Cyclic Group', fontsize=16)
ax1.legend(fontsize=12)
ax1.grid(True, alpha=0.3)

ratios = [e/l for e, l in zip(exact_gaps, lower_bounds)]
ax2.plot(ns, ratios, 'g-', linewidth=2)
ax2.axhline(y=np.pi**2, color='k', linestyle=':', label=r'$\pi^2 \approx 9.87$')
ax2.set_xlabel('n', fontsize=14)
ax2.set_ylabel('Ratio (exact / lower bound)', fontsize=14)
ax2.set_title('Tightness of Bound', fontsize=16)
ax2.legend(fontsize=12)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_gap_bound.png', dpi=150)
plt.show()