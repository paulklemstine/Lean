"""
Visualization 1: Cognitive Braid Diagrams

Visualizes canonical cognitive braids (identity, trefoil, figure-eight)
as strand diagrams, showing how neural pathways cross and interleave.
Each braid represents a different type of cognitive process.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_braid(ax, title, generators, n_strands=3, color_map=None):
    """
    Draw a braid diagram on the given axes.

    generators: list of (strand_index, sign) tuples
    """
    if color_map is None:
        color_map = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']

    segment_width = 1.5
    total_width = len(generators) * segment_width + 1
    strand_spacing = 1.0

    # Track strand positions
    positions = list(range(n_strands))

    # Draw each crossing
    x_start = 0.5
    for seg_idx, (strand_idx, sign) in enumerate(generators):
        x = x_start + seg_idx * segment_width
        x_next = x + segment_width

        # Draw all strands
        for s in range(n_strands):
            pos = positions[s]
            if s == strand_idx or s == strand_idx + 1:
                continue
            # Straight strand
            ax.plot([x, x_next], [pos * strand_spacing, pos * strand_spacing],
                    color=color_map[s % len(color_map)], linewidth=3, solid_capstyle='round')

        # Draw crossing strands
        top_strand = strand_idx if sign == 1 else strand_idx + 1
        bot_strand = strand_idx + 1 if sign == 1 else strand_idx

        top_pos = positions[top_strand] * strand_spacing
        bot_pos = positions[bot_strand] * strand_spacing

        # Over strand (continuous)
        t = np.linspace(0, 1, 50)
        over_y = top_pos + (bot_pos - top_pos) * (0.5 - 0.5 * np.cos(np.pi * t))
        ax.plot(x + t * segment_width, over_y,
                color=color_map[top_strand % len(color_map)], linewidth=4,
                solid_capstyle='round', zorder=3)

        # Under strand (with gap)
        under_y = bot_pos + (top_pos - bot_pos) * (0.5 - 0.5 * np.cos(np.pi * t))
        gap_mask = (t > 0.35) & (t < 0.65)
        under_y_masked = np.ma.array(under_y, mask=gap_mask)
        ax.plot(x + t * segment_width, under_y_masked,
                color=color_map[bot_strand % len(color_map)], linewidth=3,
                solid_capstyle='round', zorder=2)

        # Update positions
        positions[top_strand], positions[bot_strand] = positions[bot_strand], positions[top_strand]

    # Draw final straight segments
    x_end = x_start + len(generators) * segment_width
    for s in range(n_strands):
        pos = positions[s] * strand_spacing
        ax.plot([x_end, x_end + 0.5], [pos, pos],
                color=color_map[s % len(color_map)], linewidth=3, solid_capstyle='round')

    # Draw initial straight segments
    # Reset positions for initial
    init_pos = list(range(n_strands))
    for s in range(n_strands):
        pos = init_pos[s] * strand_spacing
        ax.plot([0, 0.5], [pos, pos],
                color=color_map[s % len(color_map)], linewidth=3, solid_capstyle='round')

    ax.set_xlim(-0.3, total_width + 0.3)
    ax.set_ylim(-0.5, (n_strands - 0.5) * strand_spacing)
    ax.set_title(title, fontsize=14, fontweight='bold', pad=10)
    ax.set_aspect('equal')
    ax.axis('off')


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Cognitive Braid Diagrams: Thinking as Topology',
             fontsize=18, fontweight='bold', y=0.98)

# Identity braid (no crossings) — linear thought
ax = axes[0, 0]
draw_braid(ax, 'Identity Braid\n(Linear Thought)\nWrithe = 0, Level = trivial', [], n_strands=3)

# Trefoil braid (σ₁³) — creative insight
ax = axes[0, 1]
draw_braid(ax, 'Trefoil Braid (σ₁³)\n(Creative Insight)\nWrithe = 3, Level = moderate',
           [(0, 1), (0, 1), (0, 1)], n_strands=3)

# Figure-eight braid — confused thinking
ax = axes[1, 0]
draw_braid(ax, 'Figure-Eight Braid (σ₁σ₂⁻¹σ₁σ₂⁻¹)\n(Confused Thinking)\nWrithe = 0, Level = moderate',
           [(0, 1), (1, -1), (0, 1), (1, -1)], n_strands=3)

# Full twist braid — deep focus
ax = axes[1, 1]
draw_braid(ax, 'Full Twist (σ₁σ₂σ₁σ₂σ₁σ₂)\n(Deep Focus)\nWrithe = 6, Level = complex',
           [(0, 1), (1, 1), (0, 1), (1, 1), (0, 1), (1, 1)], n_strands=3)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_braid_strands.png', dpi=150, bbox_inches='tight')
print("Saved viz_braid_strands.png")
