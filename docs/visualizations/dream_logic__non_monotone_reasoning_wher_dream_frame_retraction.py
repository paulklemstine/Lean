#!/usr/bin/env python3
"""
Visualization: Dream Frame Structure and Non-Monotone Retraction

Shows how adding accessibility connections retracts beliefs.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_frame(ax, title, worlds, access, val, beliefs_at_0):
    """Draw a dream frame diagram."""
    n = len(worlds)
    positions = {0: (-1, 0), 1: (1, 0)} if n == 2 else {i: (i, 0) for i in range(n)}
    
    # Draw accessibility arrows
    for w, targets in access.items():
        for t in targets:
            if w == t:
                # Self-loop
                x, y = positions[w]
                arc = mpatches.FancyArrowPatch(
                    (x - 0.15, y + 0.4), (x + 0.15, y + 0.4),
                    connectionstyle="arc3,rad=1.5",
                    arrowstyle='->', mutation_scale=15,
                    color='blue', linewidth=2
                )
                ax.add_patch(arc)
            else:
                x1, y1 = positions[w]
                x2, y2 = positions[t]
                ax.annotate('', xy=(x2, y2 + 0.35), xytext=(x1, y1 + 0.35),
                          arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    
    # Draw worlds
    for w in worlds:
        x, y = positions[w]
        state = val[w]
        
        # World circle
        color = '#FFFFAA' if state['contra'] else '#AAFFAA'
        circle = plt.Circle((x, y), 0.35, color=color, ec='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y + 0.05, f'w{w}', ha='center', va='center', fontsize=12, 
                fontweight='bold', zorder=6)
        
        # State info below
        pos_str = '{' + ','.join(str(p) for p in sorted(state['pos'])) + '}'
        neg_str = '{' + ','.join(str(p) for p in sorted(state['neg'])) + '}'
        ax.text(x, y - 0.55, f'pos={pos_str}', ha='center', fontsize=9)
        ax.text(x, y - 0.75, f'neg={neg_str}', ha='center', fontsize=9)
        if state['contra']:
            ax.text(x, y - 0.95, f'⚡contra', ha='center', fontsize=9, color='red')
    
    # Beliefs box
    beliefs_str = '{' + ','.join(str(p) for p in sorted(beliefs_at_0)) + '}'
    ax.text(0, -1.5, f'Beliefs at w0: {beliefs_str}', ha='center', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.7))
    
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 1.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.axis('off')


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Frame 1: restricted access
    draw_frame(ax1, 'Frame 1: Restricted Access\n(w0 sees only itself)',
               worlds=[0, 1],
               access={0: {0}, 1: {1}},
               val={
                   0: {'pos': {0, 1}, 'neg': set(), 'contra': False},
                   1: {'pos': set(), 'neg': {0}, 'contra': False},
               },
               beliefs_at_0={0, 1})
    
    # Frame 2: extended access
    draw_frame(ax2, 'Frame 2: Extended Access\n(w0 sees both worlds)',
               worlds=[0, 1],
               access={0: {0, 1}, 1: {1}},
               val={
                   0: {'pos': {0, 1}, 'neg': set(), 'contra': False},
                   1: {'pos': set(), 'neg': {0}, 'contra': False},
               },
               beliefs_at_0=set())
    
    # Arrow between frames
    fig.text(0.5, 0.02, '→ Adding w0→w1 access RETRACTS beliefs {0,1} → ∅',
             ha='center', fontsize=13, fontweight='bold', color='red',
             bbox=dict(boxstyle='round', facecolor='mistyrose'))
    
    fig.suptitle('Non-Monotone Belief Retraction in Dream Frames', 
                 fontsize=15, fontweight='bold')
    plt.tight_layout(rect=[0, 0.08, 1, 0.95])
    plt.savefig('dream_retraction.png', dpi=150, bbox_inches='tight')
    print("Saved dream_retraction.png")


if __name__ == "__main__":
    main()
