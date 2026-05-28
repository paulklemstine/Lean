#!/usr/bin/env python3
"""
Visualization 2: Lower Bound Transfer Theorem

Illustrates the transfer of resolution lower bounds to certificate lower bounds.
Shows how the bridge between proof systems propagates hardness:
  - Resolution lower bound L → Certificate lower bound ⌈L/2⌉
  - Exponential resolution hardness → Exponential certificate hardness

Creates a figure with:
  - Left panel: Transfer function L → ⌈(L+1)/2⌉
  - Right panel: Known/conjectured exponential bounds for PHP
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np


# ============================================================
# Transfer function (Theorem 3)
# ============================================================

def transferred_lower_bound(L):
    """Certificate lower bound from resolution lower bound."""
    return (L + 1) // 2


# ============================================================
# PHP bounds (theoretical)
# ============================================================

def php_resolution_lower_bound(n):
    """Known exponential lower bound for PHP resolution (Haken 1985).
    Actual bound: 2^(n/20) for tree-like resolution of PHP(n+1, n)."""
    return 2 ** (n / 20)


def php_certificate_lower_bound(n):
    """Transferred certificate lower bound."""
    res_bound = php_resolution_lower_bound(n)
    return transferred_lower_bound(int(res_bound))


# ============================================================
# Create visualization
# ============================================================

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Lower Bound Transfer: Resolution → Certificate Complexity',
             fontsize=14, fontweight='bold')

# Left panel: Transfer function
ax = axes[0]
Ls = np.arange(1, 101)
transferred = [(L + 1) // 2 for L in Ls]

ax.plot(Ls, transferred, 'b-', linewidth=2, label='⌈(L+1)/2⌉ (certificate bound)')
ax.plot(Ls, Ls, 'r--', linewidth=1, alpha=0.5, label='L (resolution bound)')
ax.plot(Ls, Ls / 2, 'g--', linewidth=1, alpha=0.5, label='L/2')
ax.fill_between(Ls, transferred, Ls, alpha=0.1, color='blue',
                label='Gap (linear overhead)')

ax.set_xlabel('Resolution Lower Bound (L)', fontsize=12)
ax.set_ylabel('Certificate Lower Bound', fontsize=12)
ax.set_title('Transfer Function (Theorem 3)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right panel: PHP exponential bounds
ax = axes[1]
ns = np.arange(1, 51)

res_bounds = [2 ** (n / 20) for n in ns]
cert_bounds = [(2 ** (n / 20) + 1) / 2 for n in ns]

ax.semilogy(ns, res_bounds, 'r-', linewidth=2, label='Resolution: 2^(n/20)')
ax.semilogy(ns, cert_bounds, 'b-', linewidth=2, label='Certificate: ≥ 2^(n/20)/2')
ax.fill_between(ns, cert_bounds, res_bounds, alpha=0.1, color='purple')

# Mark specific points
for n_mark in [10, 20, 30, 40]:
    res_val = 2 ** (n_mark / 20)
    cert_val = (res_val + 1) / 2
    ax.plot(n_mark, res_val, 'ro', markersize=8)
    ax.plot(n_mark, cert_val, 'bs', markersize=8)

ax.set_xlabel('n (pigeons - 1)', fontsize=12)
ax.set_ylabel('Minimum proof/certificate size', fontsize=12)
ax.set_title('PHP Exponential Bounds (Haken → Transfer)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Add annotation
ax.annotate('Both grow\nexponentially!',
            xy=(35, 2**(35/20)),
            xytext=(25, 2**(40/20)),
            arrowprops=dict(arrowstyle='->', color='black'),
            fontsize=11, ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.7))

plt.tight_layout()
plt.savefig('viz_transfer_theorem.png', dpi=150, bbox_inches='tight')
print("Saved viz_transfer_theorem.png")
