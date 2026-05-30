"""
Shadow Tower Heatmap Visualization
===================================
Visualizes the shadow tower cardinalities as a heatmap,
showing how |Sh_k(T(d,m))| varies with d, m, and k.

The heatmap reveals the decay pattern: higher k means fewer
support elements, while higher d means more elements at each level.
"""
import numpy as np
import matplotlib.pyplot as plt
from math import comb


def simplex_card(d: int, m: int) -> int:
    """C(m + d - 1, d - 1)"""
    if d <= 0 or m < 0:
        return 0
    return comb(m + d - 1, d - 1)


# Parameters
m_max = 15
k_max = 15
d = 4  # Fix dimension

# Build the heatmap data
data = np.zeros((k_max + 1, m_max + 1))
for m in range(m_max + 1):
    for k in range(min(k_max, m) + 1):
        data[k, m] = simplex_card(d, m - k)

# Use log scale for better visualization
log_data = np.log10(data + 1)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Heatmap of |Sh_k(T(d,m))|
ax = axes[0]
im = ax.imshow(log_data, aspect='auto', origin='lower', cmap='YlOrRd',
               extent=[-0.5, m_max + 0.5, -0.5, k_max + 0.5])
ax.set_xlabel('Degree m', fontsize=12)
ax.set_ylabel('Shadow order k', fontsize=12)
ax.set_title(f'log₁₀(|Sh_k(T({d}, m))| + 1)', fontsize=14)
fig.colorbar(im, ax=ax, label='log₁₀(cardinality + 1)')

# Add the "forbidden zone" line k = m
ax.plot([0, m_max], [0, m_max], 'w--', linewidth=2, label='k = m (boundary)')
ax.legend(loc='upper left', fontsize=10)

# Right: Shadow ratio decay curves
ax = axes[1]
for d_val in [2, 3, 4, 5, 8]:
    m = 20
    ks = range(m + 1)
    ratios = [simplex_card(d_val, m - k) / simplex_card(d_val, m) 
              for k in ks]
    ax.plot(ks, ratios, 'o-', markersize=3, label=f'd = {d_val}')

ax.set_xlabel('Shadow order k', fontsize=12)
ax.set_ylabel('Shadow ratio |Sh_k| / |S|', fontsize=12)
ax.set_title(f'Shadow Decay Curves (m = 20)', fontsize=14)
ax.legend(fontsize=10)
ax.set_ylim(-0.05, 1.05)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('shadow_tower_heatmap.png', dpi=150, bbox_inches='tight')
plt.show()
