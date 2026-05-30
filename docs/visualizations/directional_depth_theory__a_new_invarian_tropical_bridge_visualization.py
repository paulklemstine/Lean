"""
Visualization: Tropical Bridge — Log-Concavity meets Tropical Geometry
======================================================================

Shows the correspondence between log-concavity in the multiplicative world
and tropical concavity in the additive world. The key theorem states that
a positive sequence is log-concave iff its logarithm is tropical-concave.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


# Generate binomial coefficients
N = 15
binom = [math.comb(N, k) for k in range(N + 1)]
log_binom = [math.log(b) if b > 0 else float('-inf') for b in binom]

# Compute log-concavity ratios: a(n+1)^2 / (a(n)*a(n+2))
lc_ratios = []
for i in range(len(binom) - 2):
    if binom[i] > 0 and binom[i + 2] > 0:
        lc_ratios.append(binom[i + 1] ** 2 / (binom[i] * binom[i + 2]))

# Compute tropical gaps: 2*v(n+1) - v(n) - v(n+2)
trop_gaps = []
valid_log = [l for l in log_binom if l > float('-inf')]
for i in range(len(valid_log) - 2):
    trop_gaps.append(2 * valid_log[i + 1] - valid_log[i] - valid_log[i + 2])

# Ratio transform
rt = [binom[i + 1] / binom[i] for i in range(len(binom) - 1) if binom[i] > 0]

# Create figure
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top-left: Original sequence
ax1 = axes[0, 0]
ax1.bar(range(N + 1), binom, color='steelblue', alpha=0.7)
ax1.set_xlabel('k', fontsize=11)
ax1.set_ylabel('C(N, k)', fontsize=11)
ax1.set_title(f'Binomial Coefficients C({N}, k)', fontsize=13)
ax1.grid(True, alpha=0.3)

# Top-right: Log of sequence (tropical world)
ax2 = axes[0, 1]
valid_indices = [i for i, l in enumerate(log_binom) if l > float('-inf')]
valid_logs = [l for l in log_binom if l > float('-inf')]
ax2.plot(valid_indices, valid_logs, 'ro-', markersize=6, linewidth=2)
ax2.fill_between(valid_indices, valid_logs, alpha=0.2, color='red')
ax2.set_xlabel('k', fontsize=11)
ax2.set_ylabel('log C(N, k)', fontsize=11)
ax2.set_title('Tropical View: log C(N, k)', fontsize=13)
ax2.grid(True, alpha=0.3)

# Bottom-left: Log-concavity ratios (should be >= 1)
ax3 = axes[1, 0]
ax3.bar(range(1, len(lc_ratios) + 1), lc_ratios, color='green', alpha=0.7)
ax3.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Threshold = 1')
ax3.set_xlabel('n', fontsize=11)
ax3.set_ylabel('a(n+1)² / (a(n)·a(n+2))', fontsize=11)
ax3.set_title('Log-Concavity Ratios (≥1 required)', fontsize=13)
ax3.legend()
ax3.grid(True, alpha=0.3)

# Bottom-right: Tropical concavity gaps (should be >= 0)
ax4 = axes[1, 1]
colors = ['green' if g >= 0 else 'red' for g in trop_gaps]
ax4.bar(range(1, len(trop_gaps) + 1), trop_gaps, color=colors, alpha=0.7)
ax4.axhline(y=0, color='red', linestyle='--', linewidth=2, label='Threshold = 0')
ax4.set_xlabel('n', fontsize=11)
ax4.set_ylabel('2v(n+1) - v(n) - v(n+2)', fontsize=11)
ax4.set_title('Tropical Concavity Gaps (≥0 required)', fontsize=13)
ax4.legend()
ax4.grid(True, alpha=0.3)

plt.suptitle('Tropical Bridge: Log-Concavity ↔ Tropical Concavity',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tropical_bridge.png', dpi=150, bbox_inches='tight')
print("Saved tropical_bridge.png")
