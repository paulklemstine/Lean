"""
Visualization: Coding Theory Bridge
=====================================
Shows how the spectral gap of symplectic expanders translates into
error-correcting code parameters. This visualizes the cross-domain
bridge from expansion certificates to coding theory (Sipser-Spielman
/ Tanner codes).
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Code distance vs spectral gap
ax = axes[0]
gaps = np.linspace(0.01, 0.99, 200)
inner_distances = [0.3, 0.4, 0.5, 0.6, 0.7]
block_length = 1000
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(inner_distances)))

for inner_d, color in zip(inner_distances, colors):
    distances = [(inner_d - (1 - g)) * block_length for g in gaps]
    distances = [max(0, d) for d in distances]
    ax.plot(gaps, distances, color=color, linewidth=2, label=f'δ_inner = {inner_d}')

ax.fill_between(gaps, 0, alpha=0.1, color='red')
ax.set_xlabel('Spectral Gap ε', fontsize=12)
ax.set_ylabel('Code Distance Lower Bound', fontsize=12)
ax.set_title('Expander Code Distance from Spectral Gap\n(n = 1000)', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)
ax.set_ylim(0, 700)

# Add annotations for key regions
ax.annotate('Expansion regime\n(distance > 0)', xy=(0.7, 200), fontsize=10,
            ha='center', style='italic', color='darkgreen')
ax.annotate('No distance\nguarantee', xy=(0.15, 50), fontsize=10,
            ha='center', style='italic', color='red')

# Panel 2: Rate-distance tradeoff for different group ranks
ax2 = axes[1]
inner_d = 0.5

for n, color, marker in [(1, '#e41a1c', 'o'), (2, '#377eb8', 's'), 
                           (3, '#4daf4a', '^'), (5, '#984ea3', 'D')]:
    rates = []
    dist_fractions = []
    
    for q in range(n + 3, 200):
        gap = 1.0 - (n + 1) / q
        dist_frac = inner_d - (1.0 - gap)
        
        if dist_frac > 0:
            # Rate depends on code construction; use simplified model
            rate = 0.5  # fixed for comparison
            rates.append(gap)  # use gap as proxy for achievable rate
            dist_fractions.append(dist_frac)
    
    if rates:
        ax2.plot(rates, dist_fractions, color=color, linewidth=2,
                label=f'Sp₂ₙ, n={n}', alpha=0.8)

# Singleton bound reference
gap_ref = np.linspace(0.01, 0.99, 100)
singleton = 1 - gap_ref  # simplified
ax2.plot(gap_ref, [0.5 - (1-g) for g in gap_ref if 0.5 > 1-g],
         'k--', linewidth=1, alpha=0.5, label='δ = gap + δ_inner - 1')

ax2.set_xlabel('Spectral Gap ε', fontsize=12)
ax2.set_ylabel('Relative Distance δ/n', fontsize=12)
ax2.set_title('Rate-Distance from Symplectic Certificates\n(inner distance = 0.5)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0.5, 1.0)
ax2.set_ylim(0, 0.5)

plt.tight_layout()
plt.savefig('code_distance_bridge.png', dpi=150, bbox_inches='tight')
print("Saved: code_distance_bridge.png")
