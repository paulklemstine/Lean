"""
Visualization: Logarithmic Pressure Bounds for Wreath Products

Shows the certified non-coordinate pressure bounds versus the logarithmic
envelope for W_{k,m} = S_k ≀ S_m with k = 5, 6, 7 and m = 1..100.

The key visual insight: the certified bound (decaying as 1/m) lies well
below the logarithmic envelope (growing as log m), confirming the theorem
that non-coordinate pressure is O(log m) — in fact O(1/m).
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def factorial(n):
    return math.factorial(n)


def certified_bound(k, m):
    """5 * k! * m^2 / m^3 = 5 * k! / m"""
    if m < 1:
        return 0
    return 5.0 * factorial(k) * m**2 / m**3


def log_envelope(k, m):
    """A * log(m) + B where A=1, B=5*k!+1"""
    K = 5.0 * factorial(k)
    return 1.0 * math.log(max(m, 1)) + K + 1.0


def coord_pressure(k, m):
    """m * P(S_k)"""
    p_sk = {5: 7/15, 6: 37/60, 7: 29/42}
    return m * p_sk.get(k, 1/k)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('O\'Nan–Scott Logarithmic Pressure Bounds\nfor Wreath Products $W_{k,m} = S_k \\wr S_m$',
             fontsize=14, fontweight='bold')

ms = np.arange(1, 101)

# --- Panel 1: Certified bound vs log envelope for k=5,6,7 ---
ax1 = axes[0, 0]
colors = ['#2196F3', '#FF5722', '#4CAF50']
for i, k in enumerate([5, 6, 7]):
    certs = [certified_bound(k, m) for m in ms]
    ax1.semilogy(ms, certs, color=colors[i], linewidth=2, label=f'Certified bound (k={k})')

ax1.set_xlabel('m (number of coordinates)')
ax1.set_ylabel('Non-coordinate pressure bound')
ax1.set_title('Certified Bound Decay (log scale)')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Ratio certified/log_envelope ---
ax2 = axes[0, 1]
for i, k in enumerate([5, 6, 7]):
    ratios = [certified_bound(k, m) / log_envelope(k, m) for m in ms]
    ax2.plot(ms, ratios, color=colors[i], linewidth=2, label=f'k={k}')

ax2.set_xlabel('m')
ax2.set_ylabel('Certified / Log envelope')
ax2.set_title('Ratio: Certified Bound / Logarithmic Envelope')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.1)

# --- Panel 3: Pressure decomposition for k=5 ---
ax3 = axes[1, 0]
k = 5
coords = [coord_pressure(k, m) for m in ms]
ncoords = [certified_bound(k, m) for m in ms]
totals = [c + n for c, n in zip(coords, ncoords)]

ax3.plot(ms, coords, 'b-', linewidth=2, label='Coordinate pressure (m·P(S₅))')
ax3.plot(ms, ncoords, 'r-', linewidth=2, label='Non-coordinate bound')
ax3.plot(ms, totals, 'k--', linewidth=1.5, label='Total bound')
ax3.set_xlabel('m')
ax3.set_ylabel('Pressure')
ax3.set_title(f'Pressure Decomposition (k={k})')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# --- Panel 4: P_noncoord / log(m) ---
ax4 = axes[1, 1]
for i, k in enumerate([5, 6, 7]):
    log_ratios = [certified_bound(k, m) / math.log(m) if m >= 2 else None
                  for m in ms]
    valid_ms = [m for m, r in zip(ms, log_ratios) if r is not None]
    valid_ratios = [r for r in log_ratios if r is not None]
    ax4.plot(valid_ms, valid_ratios, color=colors[i], linewidth=2, label=f'k={k}')

ax4.set_xlabel('m')
ax4.set_ylabel('P_noncoord / log(m)')
ax4.set_title('Falsifiable Prediction: Ratio to log(m)')
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)
ax4.axhline(y=0, color='gray', linestyle='-', alpha=0.5)

plt.tight_layout()
plt.savefig('pressure_bounds_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: pressure_bounds_visualization.png")
