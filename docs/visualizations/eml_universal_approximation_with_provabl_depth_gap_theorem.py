import matplotlib.pyplot as plt
import numpy as np

ns = list(range(1, 16))
poly_depths = ns
eml_depths = [3] * len(ns)
poly_sizes = [2**(n+1) - 1 for n in ns]
eml_sizes = [5] * len(ns)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
axes[0].plot(ns, poly_depths, 'ro-', lw=2, ms=8, label='Polynomial')
axes[0].plot(ns, eml_depths, 'bs-', lw=2, ms=8, label='EML')
axes[0].fill_between(ns, eml_depths, poly_depths, alpha=0.2, color='green')
axes[0].set_xlabel('n'); axes[0].set_ylabel('Depth'); axes[0].set_title('Depth Gap')
axes[0].legend(); axes[0].grid(True, alpha=0.3)
axes[1].semilogy(ns, poly_sizes, 'ro-', lw=2, ms=8, label='Polynomial')
axes[1].semilogy(ns, eml_sizes, 'bs-', lw=2, ms=8, label='EML')
axes[1].set_xlabel('n'); axes[1].set_ylabel('Size'); axes[1].set_title('Size Gap')
axes[1].legend(); axes[1].grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('depth_gap.png', dpi=150); plt.close()