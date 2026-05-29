"""
Visualization: Prime Spectrum of a Persistence Module

Shows how torsion information decomposes into independent prime channels,
each revealing different topological features at different scales.
Each row represents a prime channel; colored cells indicate where
torsion at that prime is present. The leftmost colored cell in each
row is the "birth" for that channel.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ── Define example persistence modules ──────────────────────────

# Persistence module with staggered torsion births
# F(i) groups: torsion appears at different primes at different indices
torsion_data = {
    # index: {prime: [exponents]}
    0: {},
    1: {},
    2: {7: [1]},
    3: {7: [1]},
    4: {2: [1], 7: [1]},
    5: {2: [1, 2], 3: [1], 7: [1]},
    6: {2: [1, 2], 3: [1], 5: [1], 7: [1]},
    7: {2: [1, 2], 3: [1, 1], 5: [1], 7: [1]},
    8: {2: [1, 2], 3: [1, 1], 5: [1], 7: [1], 11: [1]},
    9: {2: [1, 2], 3: [1, 1], 5: [1], 7: [1], 11: [1]},
}

primes = [2, 3, 5, 7, 11]
indices = list(range(10))
prime_colors = {
    2: '#e74c3c',   # red
    3: '#3498db',   # blue
    5: '#2ecc71',   # green
    7: '#f39c12',   # orange
    11: '#9b59b6',  # purple
}

# ── Create figure ─────────────────────────────────────────────────

fig, axes = plt.subplots(3, 1, figsize=(12, 10), gridspec_kw={'height_ratios': [4, 2, 2]})

# Panel 1: Prime spectrum heatmap
ax1 = axes[0]
for pi, p in enumerate(primes):
    for idx in indices:
        torsion = torsion_data.get(idx, {})
        has_torsion = p in torsion and len(torsion[p]) > 0
        if has_torsion:
            rank = len(torsion[p])
            alpha = min(0.3 + 0.2 * rank, 1.0)
            ax1.add_patch(plt.Rectangle((idx - 0.4, pi - 0.35), 0.8, 0.7,
                                         facecolor=prime_colors[p], alpha=alpha,
                                         edgecolor='white', linewidth=1.5))
            # Mark birth (first appearance)
            is_birth = all(p not in torsion_data.get(j, {}) or
                          len(torsion_data.get(j, {}).get(p, [])) == 0
                          for j in range(idx))
            if is_birth:
                ax1.plot(idx, pi, 'w*', markersize=14, markeredgecolor='black',
                        markeredgewidth=0.8)

ax1.set_xlim(-0.5, 9.5)
ax1.set_ylim(-0.5, len(primes) - 0.5)
ax1.set_xticks(indices)
ax1.set_yticks(range(len(primes)))
ax1.set_yticklabels([f'p = {p}' for p in primes], fontsize=12)
ax1.set_xlabel('Filtration Index', fontsize=12)
ax1.set_title('Prime Spectrum of a Persistence Module\n'
              '(★ = birth index, intensity = torsion rank)',
              fontsize=14, fontweight='bold')
ax1.grid(True, alpha=0.15)
ax1.invert_yaxis()

# Panel 2: Localization effect
ax2 = axes[1]
loc_prime = 3  # Localize at p=3

for idx in indices:
    torsion = torsion_data.get(idx, {})
    # Before localization: all torsion
    total_torsion = sum(len(torsion.get(p, [])) for p in primes)
    if total_torsion > 0:
        ax2.bar(idx - 0.2, total_torsion, width=0.35, color='gray', alpha=0.5,
               label='Before' if idx == 4 else '')

    # After localization at p=3: only 3-torsion
    p3_torsion = len(torsion.get(loc_prime, []))
    if p3_torsion > 0:
        ax2.bar(idx + 0.2, p3_torsion, width=0.35, color=prime_colors[loc_prime],
               alpha=0.8, label=f'After Loc₃' if idx == 5 else '')

ax2.set_xlim(-0.5, 9.5)
ax2.set_xticks(indices)
ax2.set_ylabel('Torsion Rank', fontsize=11)
ax2.set_title(f'Effect of Localization at p = {loc_prime}: '
              f'Isolating the {loc_prime}-primary Channel', fontsize=12)
ax2.legend(loc='upper left', fontsize=10)
ax2.grid(True, alpha=0.15)

# Panel 3: Birth set comparison
ax3 = axes[2]
y_positions = {'Global': 0}
for i, p in enumerate(primes):
    y_positions[f'p={p}'] = i + 1

# Global torsion birth
global_birth = min(idx for idx in indices if torsion_data.get(idx, {}))
ax3.barh(0, 0.6, left=global_birth - 0.3, color='black', alpha=0.7, height=0.5)
ax3.text(global_birth, 0, f'{global_birth}', ha='center', va='center',
         color='white', fontweight='bold', fontsize=10)

# Primewise births
for i, p in enumerate(primes):
    birth = None
    for idx in indices:
        if p in torsion_data.get(idx, {}) and len(torsion_data.get(idx, {}).get(p, [])) > 0:
            birth = idx
            break
    if birth is not None:
        ax3.barh(i + 1, 0.6, left=birth - 0.3, color=prime_colors[p],
                alpha=0.8, height=0.5)
        ax3.text(birth, i + 1, f'{birth}', ha='center', va='center',
                color='white', fontweight='bold', fontsize=10)

ax3.set_xlim(-0.5, 9.5)
ax3.set_xticks(indices)
ax3.set_yticks(list(y_positions.values()))
ax3.set_yticklabels(list(y_positions.keys()), fontsize=11)
ax3.set_xlabel('Filtration Index', fontsize=12)
ax3.set_title('Birth Set Decomposition: Global vs. Primewise',
              fontsize=12)
ax3.grid(True, alpha=0.15, axis='x')
ax3.invert_yaxis()

plt.tight_layout()
plt.savefig('viz_prime_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_prime_spectrum.png")
