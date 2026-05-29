"""
Visualization: The Localization Functor in Action

Shows how two persistence modules that are δ-interleaved remain
δ-interleaved after localization at a prime. The visualization
depicts the groups at each index, the interleaving maps, and
how localization simplifies the picture by removing extraneous torsion.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ── Configuration ─────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 9))

indices = list(range(8))
delta = 1

# Module F: torsion births
F_torsion = {
    0: {}, 1: {}, 2: {2: 1},
    3: {2: 1, 3: 1}, 4: {2: 1, 3: 1, 5: 1},
    5: {2: 1, 3: 1, 5: 1}, 6: {2: 1, 3: 1, 5: 1}, 7: {2: 1, 3: 1, 5: 1}
}
# Module G: shifted torsion births
G_torsion = {
    0: {}, 1: {}, 2: {}, 3: {2: 1},
    4: {2: 1, 3: 1}, 5: {2: 1, 3: 1, 5: 1},
    6: {2: 1, 3: 1, 5: 1}, 7: {2: 1, 3: 1, 5: 1}
}

prime_colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71'}

def torsion_label(tors):
    if not tors:
        return 'ℤ'
    parts = ['ℤ']
    for p in sorted(tors):
        parts.append(f'ℤ/{p}')
    return '⊕'.join(parts)

def draw_module(ax, torsion_data, name, y_offset=0, color='black'):
    """Draw a persistence module as a sequence of nodes with labels."""
    for i in indices:
        tors = torsion_data.get(i, {})
        n_primes = len(tors)

        # Node
        circle_color = '#f0f0f0' if n_primes == 0 else '#fff3e0'
        ax.add_patch(plt.Circle((i, y_offset), 0.35, facecolor=circle_color,
                                edgecolor=color, linewidth=1.5, zorder=3))

        # Torsion indicators
        for j, (p, _) in enumerate(sorted(tors.items())):
            angle = 2 * np.pi * j / max(n_primes, 1) - np.pi/2
            dx, dy = 0.15 * np.cos(angle), 0.15 * np.sin(angle)
            ax.plot(i + dx, y_offset + dy, 'o', color=prime_colors.get(p, 'gray'),
                   markersize=6, zorder=4)

        # Arrows between nodes
        if i < max(indices):
            ax.annotate('', xy=(i + 0.6, y_offset), xytext=(i + 0.4, y_offset),
                       arrowprops=dict(arrowstyle='->', color=color, lw=1.2))

    ax.text(-0.8, y_offset, name, fontsize=13, fontweight='bold',
            ha='right', va='center', color=color)

def draw_interleaving(ax, y_top, y_bot, delta_val):
    """Draw interleaving arrows between two modules."""
    for i in indices:
        if i + delta_val <= max(indices):
            # Forward arrow (top to bottom)
            ax.annotate('', xy=(i + delta_val, y_bot + 0.4),
                       xytext=(i, y_top - 0.4),
                       arrowprops=dict(arrowstyle='->', color='#27ae60',
                                      lw=1, ls='--', alpha=0.5))
            # Backward arrow (bottom to top)
            ax.annotate('', xy=(i + delta_val, y_top - 0.4),
                       xytext=(i, y_bot + 0.4),
                       arrowprops=dict(arrowstyle='->', color='#e67e22',
                                      lw=1, ls='--', alpha=0.5))

# ── Panel 1: Original modules with interleaving ──────────────────

ax = axes[0, 0]
draw_module(ax, F_torsion, 'F', y_offset=1.5, color='#2c3e50')
draw_module(ax, G_torsion, 'G', y_offset=-1.5, color='#8e44ad')
draw_interleaving(ax, 1.5, -1.5, delta)

ax.set_xlim(-1.5, 8)
ax.set_ylim(-2.5, 2.5)
ax.set_xticks(indices)
ax.set_title(f'Original: F and G are δ={delta}-interleaved\n(colored dots = torsion at primes)',
             fontsize=11, fontweight='bold')
ax.set_xlabel('Filtration Index', fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.1)

# ── Panel 2: Localized at p=2 ─────────────────────────────────────

ax = axes[0, 1]
F_loc2 = {i: ({2: t[2]} if 2 in t else {}) for i, t in F_torsion.items()}
G_loc2 = {i: ({2: t[2]} if 2 in t else {}) for i, t in G_torsion.items()}

draw_module(ax, F_loc2, 'Loc₂(F)', y_offset=1.5, color='#c0392b')
draw_module(ax, G_loc2, 'Loc₂(G)', y_offset=-1.5, color='#8e44ad')
draw_interleaving(ax, 1.5, -1.5, delta)

ax.set_xlim(-1.5, 8)
ax.set_ylim(-2.5, 2.5)
ax.set_xticks(indices)
ax.set_title(f'Localized at p=2: Only 2-torsion survives\nδ={delta}-interleaving preserved!',
             fontsize=11, fontweight='bold')
ax.set_xlabel('Filtration Index', fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.1)

# ── Panel 3: Localized at p=3 ─────────────────────────────────────

ax = axes[1, 0]
F_loc3 = {i: ({3: t[3]} if 3 in t else {}) for i, t in F_torsion.items()}
G_loc3 = {i: ({3: t[3]} if 3 in t else {}) for i, t in G_torsion.items()}

draw_module(ax, F_loc3, 'Loc₃(F)', y_offset=1.5, color='#2980b9')
draw_module(ax, G_loc3, 'Loc₃(G)', y_offset=-1.5, color='#8e44ad')
draw_interleaving(ax, 1.5, -1.5, delta)

ax.set_xlim(-1.5, 8)
ax.set_ylim(-2.5, 2.5)
ax.set_xticks(indices)
ax.set_title(f'Localized at p=3: Only 3-torsion survives\nδ={delta}-interleaving preserved!',
             fontsize=11, fontweight='bold')
ax.set_xlabel('Filtration Index', fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.1)

# ── Panel 4: Birth set comparison ─────────────────────────────────

ax = axes[1, 1]

labels = ['Global F', 'Global G', 'p=2 F', 'p=2 G', 'p=3 F', 'p=3 G', 'p=5 F', 'p=5 G']
births = [2, 3, 2, 3, 3, 4, 4, 5]
colors_list = ['#2c3e50', '#8e44ad', '#e74c3c', '#e74c3c', '#3498db', '#3498db', '#2ecc71', '#2ecc71']
alphas = [0.9, 0.9, 0.8, 0.5, 0.8, 0.5, 0.8, 0.5]

y_pos = list(range(len(labels)))
bars = ax.barh(y_pos, [0.6]*len(labels), left=[b-0.3 for b in births],
               color=colors_list, alpha=alphas, height=0.6, edgecolor='white')

for i, (birth, label) in enumerate(zip(births, labels)):
    ax.text(birth, i, str(birth), ha='center', va='center',
            color='white', fontweight='bold', fontsize=9)

# Draw distance brackets
for pair_start in [0, 2, 4, 6]:
    b1, b2 = births[pair_start], births[pair_start + 1]
    dist = abs(b1 - b2)
    mid_y = pair_start + 0.5
    ax.annotate(f'Δ={dist}', xy=(max(b1, b2) + 0.5, mid_y),
               fontsize=9, color='#e67e22', fontweight='bold')

ax.set_xlim(-0.5, 8)
ax.set_yticks(y_pos)
ax.set_yticklabels(labels, fontsize=9)
ax.set_xlabel('Filtration Index', fontsize=10)
ax.set_title('Birth Indices: Global vs. Primewise\n'
             '(Theorem 2: p-births = localized births)',
             fontsize=11, fontweight='bold')
ax.grid(True, alpha=0.1, axis='x')
ax.invert_yaxis()

# Legend
legend_patches = [mpatches.Patch(color=prime_colors[p], label=f'p={p} torsion')
                  for p in [2, 3, 5]]
fig.legend(handles=legend_patches, loc='lower center', ncol=3,
           fontsize=10, frameon=True, fancybox=True)

plt.tight_layout(rect=[0, 0.05, 1, 1])
plt.savefig('viz_localization_functor.png', dpi=150, bbox_inches='tight')
print("Saved viz_localization_functor.png")
