"""
Visualization: Topology Lattice and Phantom Spectrum

Visualizes the complete lattice of topologies on {0,1} and highlights
the phantom spectrum of a two-observer system. Shows how different
observer combinations produce different consensus topologies.

Uses matplotlib to create a Hasse diagram of the topology lattice
with the phantom spectrum highlighted in color.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# The 4 topologies on {0, 1}
# In Mathlib's ordering: ≤ means "finer" (more open sets)
# ⊥ = discrete (finest), ⊤ = indiscrete (coarsest)
topologies = {
    "discrete": {"∅", "{0}", "{1}", "{0,1}"},       # ⊥, 4 open sets
    "Sierpinski-0": {"∅", "{0}", "{0,1}"},           # 3 open sets
    "Sierpinski-1": {"∅", "{1}", "{0,1}"},           # 3 open sets
    "indiscrete": {"∅", "{0,1}"},                     # ⊤, 2 open sets
}

# Positions in the Hasse diagram (x, y)
positions = {
    "discrete": (0, 0),
    "Sierpinski-0": (-1.2, 1.5),
    "Sierpinski-1": (1.2, 1.5),
    "indiscrete": (0, 3),
}

# Edges in the Hasse diagram (finer → coarser)
edges = [
    ("discrete", "Sierpinski-0"),
    ("discrete", "Sierpinski-1"),
    ("Sierpinski-0", "indiscrete"),
    ("Sierpinski-1", "indiscrete"),
]

fig, axes = plt.subplots(1, 3, figsize=(16, 6))

# --- Panel 1: Full Topology Lattice ---
ax = axes[0]
ax.set_title("Topology Lattice on {0, 1}", fontsize=13, fontweight='bold')

for name, (x, y) in positions.items():
    circle = plt.Circle((x, y), 0.4, fill=True, color='#4ECDC4',
                         edgecolor='#2C3E50', linewidth=2, zorder=5)
    ax.add_patch(circle)
    ax.text(x, y + 0.05, name.replace("-", "-\n") if "Sierpinski" in name else name,
            ha='center', va='center', fontsize=8, fontweight='bold', zorder=6)
    ax.text(x, y - 0.25, f"|opens|={len(topologies[name])}",
            ha='center', va='center', fontsize=7, color='#2C3E50', zorder=6)

for a, b in edges:
    xa, ya = positions[a]
    xb, yb = positions[b]
    ax.annotate("", xy=(xb, yb - 0.4), xytext=(xa, ya + 0.4),
                arrowprops=dict(arrowstyle='->', color='#7F8C8D', lw=1.5))

ax.text(0, -0.9, "⊥ = discrete (finest)", ha='center', fontsize=9, style='italic')
ax.text(0, 3.8, "⊤ = indiscrete (coarsest)", ha='center', fontsize=9, style='italic')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-1.5, 4.5)
ax.set_aspect('equal')
ax.axis('off')

# --- Panel 2: Phantom Spectrum ---
ax = axes[1]
ax.set_title("Phantom Spectrum\n(Observers: Sierp-0, Sierp-1)", fontsize=13, fontweight='bold')

# Spectrum = {discrete, Sierp-0, Sierp-1, indiscrete}
# S=∅ → discrete, S={0} → Sierp-0, S={1} → Sierp-1, S={0,1} → indiscrete
spectrum_labels = {
    "discrete": "S = ∅",
    "Sierpinski-0": "S = {obs₁}",
    "Sierpinski-1": "S = {obs₂}",
    "indiscrete": "S = {obs₁, obs₂}",
}

spectrum_colors = {
    "discrete": '#E74C3C',
    "Sierpinski-0": '#3498DB',
    "Sierpinski-1": '#F39C12',
    "indiscrete": '#9B59B6',
}

for name, (x, y) in positions.items():
    color = spectrum_colors[name]
    circle = plt.Circle((x, y), 0.4, fill=True, color=color,
                         edgecolor='#2C3E50', linewidth=2, zorder=5, alpha=0.85)
    ax.add_patch(circle)
    ax.text(x, y + 0.08, name.replace("-", "-\n") if "Sierpinski" in name else name,
            ha='center', va='center', fontsize=8, fontweight='bold', zorder=6, color='white')
    ax.text(x, y - 0.55, spectrum_labels[name],
            ha='center', va='center', fontsize=8, zorder=6,
            bbox=dict(boxstyle='round,pad=0.2', facecolor=color, alpha=0.3))

for a, b in edges:
    xa, ya = positions[a]
    xb, yb = positions[b]
    ax.annotate("", xy=(xb, yb - 0.4), xytext=(xa, ya + 0.4),
                arrowprops=dict(arrowstyle='->', color='#7F8C8D', lw=1.5))

ax.text(0, -1.2, "Phantom Entropy = 4 - 1 = 3", ha='center', fontsize=10,
        fontweight='bold', color='#2C3E50')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-1.8, 4.5)
ax.set_aspect('equal')
ax.axis('off')

# --- Panel 3: Filtration Timeline ---
ax = axes[2]
ax.set_title("Phantom Filtration\n(Sequential Observer Addition)", fontsize=13, fontweight='bold')

# Filtration: Stage 0 = discrete, Stage 1 = Sierp-0, Stage 2 = indiscrete
stages = [
    (0, "discrete", '#E74C3C', 4),
    (1, "Sierpinski-0", '#3498DB', 3),
    (2, "indiscrete", '#9B59B6', 2),
]

x_pos = [0, 1.5, 3]
y_pos = [2, 2, 2]

for i, (stage, name, color, nopen) in enumerate(stages):
    circle = plt.Circle((x_pos[i], y_pos[i]), 0.5, fill=True, color=color,
                         edgecolor='#2C3E50', linewidth=2, zorder=5, alpha=0.85)
    ax.add_patch(circle)
    ax.text(x_pos[i], y_pos[i] + 0.1, f"Stage {stage}", ha='center', va='center',
            fontsize=9, fontweight='bold', color='white', zorder=6)
    ax.text(x_pos[i], y_pos[i] - 0.15, name.replace("Sierpinski-0", "Sierp-0"),
            ha='center', va='center', fontsize=7, color='white', zorder=6)
    ax.text(x_pos[i], y_pos[i] - 0.7, f"|opens|={nopen}", ha='center',
            fontsize=8, color='#2C3E50')

# Arrows between stages
for i in range(len(stages) - 1):
    ax.annotate("", xy=(x_pos[i+1] - 0.5, y_pos[i+1]),
                xytext=(x_pos[i] + 0.5, y_pos[i]),
                arrowprops=dict(arrowstyle='->', color='#2C3E50', lw=2))
    label = f"+obs{i+1}" if i == 0 else f"+obs{i+1}"
    ax.text((x_pos[i] + x_pos[i+1]) / 2, y_pos[i] + 0.4, f"+observer {i+1}",
            ha='center', fontsize=8, color='#7F8C8D')

# Monotonicity arrow
ax.annotate("", xy=(3.5, 0.5), xytext=(-0.5, 0.5),
            arrowprops=dict(arrowstyle='->', color='#95A5A6', lw=1, linestyle='dashed'))
ax.text(1.5, 0.2, "consensus gets coarser →", ha='center', fontsize=9,
        color='#95A5A6', style='italic')

ax.set_xlim(-1, 4)
ax.set_ylim(-0.5, 3.5)
ax.set_aspect('equal')
ax.axis('off')

plt.tight_layout()
plt.savefig('topology_lattice.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved: topology_lattice.png")
