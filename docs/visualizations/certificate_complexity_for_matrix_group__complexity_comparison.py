#!/usr/bin/env python3
"""
Visualization: Certificate Verification Cost vs Subgroup Enumeration Cost

This plot illustrates the central complexity separation of the certificate
paradigm: certificate verification grows as O(n³) while subgroup enumeration
grows as O(q^(n²)), creating an exponential gap that widens with dimension.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Left panel: Cost vs dimension for fixed q ---
ax1 = axes[0]
dims = np.arange(2, 13)
cert_cost = 20 * dims**3 + 3 * dims**2

for q in [2, 3, 5, 7]:
    enum_cost = np.array([q ** (n * n) for n in dims], dtype=float)
    enum_cost = np.minimum(enum_cost, 1e30)
    ax1.semilogy(dims, enum_cost, 'o--', label=f'Enumeration (q={q})', alpha=0.7)

ax1.semilogy(dims, cert_cost, 's-', color='black', linewidth=2.5,
             markersize=8, label='Certificate (O(n³))', zorder=5)

ax1.fill_between(dims, cert_cost, 1e30, alpha=0.08, color='green')
ax1.fill_between(dims, 1, cert_cost, alpha=0.05, color='red')

ax1.set_xlabel('Matrix dimension n', fontsize=13)
ax1.set_ylabel('Field operations (log scale)', fontsize=13)
ax1.set_title('Certificate vs Enumeration Cost', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.set_ylim(1, 1e30)
ax1.set_xlim(2, 12)
ax1.grid(True, alpha=0.3)

ax1.annotate('Exponential\ngap', xy=(7, 1e10), fontsize=12,
            ha='center', color='darkgreen', fontweight='bold')

# --- Right panel: Crossover point ---
ax2 = axes[1]
q_values = np.arange(2, 51)

for n in [2, 3, 4, 5]:
    cert = 20 * n**3 + 3 * n**2
    ratios = [q ** (n * n) / cert for q in q_values]
    ax2.semilogy(q_values, ratios, '-', linewidth=2, label=f'n={n}')
    
ax2.axhline(y=1, color='red', linestyle='--', linewidth=1.5, alpha=0.7,
            label='Break-even')

ax2.set_xlabel('Field size q', fontsize=13)
ax2.set_ylabel('Enumeration / Certificate cost ratio', fontsize=13)
ax2.set_title('Speedup Factor of Certificates', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(2, 50)

plt.tight_layout()
plt.savefig('complexity_comparison.png', dpi=150, bbox_inches='tight')
print("Saved complexity_comparison.png")
