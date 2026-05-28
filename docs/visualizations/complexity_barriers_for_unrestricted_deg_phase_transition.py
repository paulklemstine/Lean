#!/usr/bin/env python3
"""
Visualization: Phase Transition in Lorentzian Recognition Complexity

Shows the sharp transition from polynomial to exponential certificate
complexity as degree transitions from fixed to growing with n.
This visualizes the core result: complexity_phase_transition_sharp.
"""

import matplotlib.pyplot as plt
import numpy as np
import math

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Left panel: Certificate size vs n for various fixed degrees ---
ax1 = axes[0]
ns = list(range(3, 25))

for d in [3, 4, 5, 6]:
    sizes = [math.comb(n + d - 3, d - 2) for n in ns]
    ax1.plot(ns, sizes, 'o-', label=f'd = {d}', markersize=4)

# Add polynomial references
ax1.plot(ns, [n for n in ns], '--', color='gray', alpha=0.5, label='n')
ax1.plot(ns, [n**2 for n in ns], '--', color='lightgray', alpha=0.5, label='n²')

ax1.set_xlabel('Number of variables n', fontsize=12)
ax1.set_ylabel('Certificate size (quadratic leaves)', fontsize=12)
ax1.set_title('Fixed Degree: Polynomial Growth', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# --- Right panel: Certificate size for d = n (balanced regime) ---
ax2 = axes[1]
ns_balanced = list(range(4, 20))

cert_sizes = [math.comb(n + n - 3, n - 2) for n in ns_balanced]
lower_bounds = [2 ** (n - 2) for n in ns_balanced]
upper_bounds = [n ** (n - 2) for n in ns_balanced]

ax2.semilogy(ns_balanced, cert_sizes, 'rs-', label='C(2n-3, n-2)', markersize=6, linewidth=2)
ax2.semilogy(ns_balanced, lower_bounds, 'b^--', label='2^(n-2) (lower bound)', markersize=5)
ax2.semilogy(ns_balanced, upper_bounds, 'gv--', label='n^(n-2) (upper bound)', markersize=5)

# Polynomial references for comparison
for c in [2, 3, 4]:
    poly_bound = [n ** c for n in ns_balanced]
    ax2.semilogy(ns_balanced, poly_bound, ':', color='gray', alpha=0.4, linewidth=1)
    ax2.annotate(f'n^{c}', xy=(ns_balanced[-1], poly_bound[-1]),
                fontsize=8, color='gray')

ax2.set_xlabel('n = d (balanced regime)', fontsize=12)
ax2.set_ylabel('Certificate size', fontsize=12)
ax2.set_title('Growing Degree d = n: Exponential Explosion', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Add shading to show the gap
ax2.fill_between(ns_balanced, lower_bounds, cert_sizes, alpha=0.15, color='blue')
ax2.fill_between(ns_balanced, cert_sizes, upper_bounds, alpha=0.15, color='green')

plt.suptitle('Complexity Phase Transition in Lorentzian Recognition',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved phase_transition.png")
