#!/usr/bin/env python3
"""
Visualization: Musical Rhythm Patterns and Their Symmetries

Shows concrete examples of rhythms with different wallpaper-type
symmetries, visualized as 2D grids (time × voice/pitch).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(2, 4, figsize=(18, 9))

def plot_pattern(ax, pattern, title, subtitle, highlight_sym=None):
    """Plot a 2D drum pattern as a grid."""
    pattern = np.array(pattern)
    p, q = pattern.shape
    
    # Color map: onset = dark blue, silence = light gray
    cmap = plt.cm.Blues
    ax.imshow(pattern, cmap=cmap, aspect='equal', vmin=0, vmax=1,
              interpolation='nearest')
    
    # Grid lines
    for i in range(p + 1):
        ax.axhline(i - 0.5, color='white', linewidth=1)
    for j in range(q + 1):
        ax.axvline(j - 0.5, color='white', linewidth=1)
    
    # Labels
    ax.set_title(f'{title}\n{subtitle}', fontsize=11, fontweight='bold')
    ax.set_xlabel('Time →', fontsize=9)
    ax.set_ylabel('Voice ↑', fontsize=9)
    ax.set_xticks([])
    ax.set_yticks([])
    
    # Symmetry annotations
    if highlight_sym:
        for sym_type, color in highlight_sym.items():
            if sym_type == 'time_mirror':
                mid = (q - 1) / 2
                ax.axvline(mid, color=color, linewidth=3, linestyle='--', alpha=0.7)
            elif sym_type == 'pitch_mirror':
                mid = (p - 1) / 2
                ax.axhline(mid, color=color, linewidth=3, linestyle='--', alpha=0.7)
            elif sym_type == 'rotation':
                cx, cy = (q - 1) / 2, (p - 1) / 2
                circle = plt.Circle((cx, cy), 0.3, color=color, fill=True, alpha=0.5)
                ax.add_patch(circle)

# Pattern examples for each wallpaper type

# p1: No symmetry (free rhythm)
p1 = [[1,0,0,1,0,0,0,0],
      [0,0,1,0,0,0,1,0],
      [0,1,0,0,1,0,0,0],
      [1,0,0,0,0,1,0,0]]
plot_pattern(axes[0,0], p1, 'p1', 'Free rhythm\n(no symmetry)')

# pm: Mirror symmetry (palindrome)
pm = [[1,0,1,0,0,1,0,1],
      [0,1,0,1,1,0,1,0],
      [1,1,0,0,0,0,1,1],
      [0,0,1,1,1,1,0,0]]
plot_pattern(axes[0,1], pm, 'pm', 'Palindrome\n(time mirror)',
             highlight_sym={'time_mirror': '#FF5722'})

# p2: 2-fold rotation (call-and-response)
p2 = [[1,0,0,1,0,1,1,0],
      [0,1,0,0,1,0,0,1],
      [1,0,0,1,0,1,1,0],
      [0,1,1,0,1,0,0,1]]
plot_pattern(axes[0,2], p2, 'p2', 'Call-and-response\n(180° rotation)',
             highlight_sym={'rotation': '#4CAF50'})

# pmm: Double mirror (bilateral palindrome)
pmm = [[1,0,0,1,1,0,0,1],
       [0,1,1,0,0,1,1,0],
       [0,1,1,0,0,1,1,0],
       [1,0,0,1,1,0,0,1]]
plot_pattern(axes[0,3], pmm, 'pmm', 'Bilateral palindrome\n(both mirrors)',
             highlight_sym={'time_mirror': '#FF5722', 'pitch_mirror': '#2196F3'})

# pg: Glide reflection (canon)
pg = [[1,0,0,1,0,0,0,0],
      [0,0,1,0,0,1,0,0],
      [0,0,0,0,1,0,0,1],
      [0,1,0,0,0,0,1,0]]
plot_pattern(axes[1,0], pg, 'pg', 'Canon\n(glide reflection)')

# p4: 4-fold rotation (4-bar cycle)
p4 = [[1,0,0,0],
      [0,0,0,1],
      [0,0,1,0],
      [0,1,0,0]]
plot_pattern(axes[1,1], p4, 'p4', '4-bar cycle\n(90° rotation)',
             highlight_sym={'rotation': '#9C27B0'})

# p3: 3-fold rotation (3-bar blues)
p3 = [[1,0,0,1,0,0],
      [0,1,0,0,1,0],
      [0,0,1,0,0,1],
      [1,0,0,1,0,0],
      [0,1,0,0,1,0],
      [0,0,1,0,0,1]]
plot_pattern(axes[1,2], p3, 'p3', '3-bar blues\n(120° rotation)',
             highlight_sym={'rotation': '#FF9800'})

# p6m: Maximal symmetry
p6m = [[1,1,1,1,1,1],
       [1,1,1,1,1,1],
       [1,1,1,1,1,1],
       [1,1,1,1,1,1],
       [1,1,1,1,1,1],
       [1,1,1,1,1,1]]
plot_pattern(axes[1,3], p6m, 'p6m', 'Maximal symmetry\n(all symmetries)',
             highlight_sym={'time_mirror': '#FF5722', 'pitch_mirror': '#2196F3',
                           'rotation': '#4CAF50'})

plt.suptitle('Musical Drum Patterns Classified by Wallpaper Symmetry',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('rhythm_patterns.png', dpi=150, bbox_inches='tight')
print("Saved rhythm_patterns.png")
