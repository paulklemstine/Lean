"""
Visualization: TSHA vs TSHA2 Collision Resistance

Compares collision rates between single tropical hash (TSHA) and double
tropical hash (TSHA2) as a function of key dimension k.

Key insight from the Lean proof (tsha2_collision_reduction_witness):
When two messages achieve their TSHA minimum at different indices,
a generic second key will break the collision. This means TSHA2
eliminates approximately (1 - 1/k) of TSHA collisions.
"""

import numpy as np
import matplotlib.pyplot as plt
import random


def tsha(m, h):
    """Tropical hash: min_i(m_i + h_i)"""
    return min(m[i] + h[i] for i in range(len(m)))


def measure_collision_rates(k, n_pairs=20000):
    """Measure TSHA and TSHA2 collision rates for dimension k."""
    h1 = [random.randint(-50, 50) for _ in range(k)]
    h2 = [random.randint(-50, 50) for _ in range(k)]
    
    tsha_cols = 0
    tsha2_cols = 0
    
    for _ in range(n_pairs):
        m1 = [random.randint(-100, 100) for _ in range(k)]
        m2 = [random.randint(-100, 100) for _ in range(k)]
        
        if tsha(m1, h1) == tsha(m2, h1):
            tsha_cols += 1
            if tsha(m1, h2) == tsha(m2, h2):
                tsha2_cols += 1
    
    tsha_rate = tsha_cols / n_pairs
    tsha2_rate = tsha2_cols / n_pairs
    reduction = 1 - tsha2_cols / max(tsha_cols, 1)
    return tsha_rate, tsha2_rate, reduction


random.seed(42)
dims = [4, 8, 12, 16, 24, 32, 48, 64]
tsha_rates = []
tsha2_rates = []
reductions = []

for k in dims:
    tr, t2r, red = measure_collision_rates(k, n_pairs=15000)
    tsha_rates.append(tr)
    tsha2_rates.append(t2r)
    reductions.append(red)
    print(f"k={k:3d}: TSHA rate={tr:.4f}, TSHA2 rate={t2r:.4f}, reduction={red:.3f}")

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# Panel 1: Collision rates
ax1.semilogy(dims, tsha_rates, 'ro-', markersize=8, linewidth=2, label='TSHA (single key)')
ax1.semilogy(dims, tsha2_rates, 'bs-', markersize=8, linewidth=2, label='TSHA2 (double key)')
ax1.set_xlabel('Key dimension k', fontsize=12)
ax1.set_ylabel('Collision rate (log scale)', fontsize=12)
ax1.set_title('Collision Rates: TSHA vs TSHA2', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_xticks(dims)

# Panel 2: Reduction factor vs theoretical prediction
ax2.plot(dims, reductions, 'go-', markersize=8, linewidth=2, 
         label='Observed reduction')
theoretical = [1 - 1/k for k in dims]
ax2.plot(dims, theoretical, 'k--', linewidth=2, alpha=0.7,
         label='Predicted: 1 - 1/k')
ax2.set_xlabel('Key dimension k', fontsize=12)
ax2.set_ylabel('Collision reduction fraction', fontsize=12)
ax2.set_title('TSHA2 Collision Elimination Rate', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(dims)
ax2.set_ylim(0, 1.05)

# Add conjecture annotation
ax2.annotate('Conjecture: TSHA2 eliminates\n≥ (1-1/k) of TSHA collisions',
             xy=(32, 1-1/32), xytext=(20, 0.5),
             arrowprops=dict(arrowstyle='->', color='gray'),
             fontsize=10, fontstyle='italic',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

plt.suptitle('Tropical Hash Collision Analysis', fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_collision_resistance.png', dpi=150, bbox_inches='tight')
print("Saved viz_collision_resistance.png")
