"""
Visualization 2: d² = 0 Cancellation Patterns

Visualizes the algebraic constraint that d² = 0 imposes on chain complexes.
Shows how nonzero entries in d₀ and d₁ must be arranged to satisfy the
cancellation condition: lone survivors are forbidden.

Three panels:
1. A valid chain complex with canceling pairs
2. Support disjointness for diagonal-like differentials
3. The forbidden "lone survivor" pattern
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

def draw_chain_complex(ax, d1, d0, title, filt1=None, annotations=None):
    """Draw a chain complex diagram showing C₂ → C₁ → C₀."""
    n1, n2 = d1.shape
    n0_rows = d0.shape[0]
    
    # Positions
    x_positions = [0.8, 0.4, 0.0]  # C₂, C₁, C₀
    
    # Draw C₂ nodes
    c2_y = [0.5 + i * 0.3 for i in range(n2)]
    for i, y in enumerate(c2_y):
        circle = plt.Circle((x_positions[0], y), 0.06, color='#2196F3', ec='black', lw=1.5)
        ax.add_patch(circle)
        ax.text(x_positions[0], y, f'{i}', ha='center', va='center', fontsize=8, fontweight='bold', color='white')
    
    # Draw C₁ nodes
    c1_y = [0.3 + i * 0.25 for i in range(n1)]
    for i, y in enumerate(c1_y):
        color = '#4CAF50'
        if filt1 is not None:
            # Color by filtration level
            intensity = filt1[i] / max(max(filt1), 1)
            color = plt.cm.YlOrRd(0.2 + 0.6 * intensity)
        circle = plt.Circle((x_positions[1], y), 0.06, color=color, ec='black', lw=1.5)
        ax.add_patch(circle)
        label = f'{i}'
        if filt1 is not None:
            label = f'{filt1[i]}'
        ax.text(x_positions[1], y, label, ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Draw C₀ nodes
    c0_y = [0.5 + i * 0.3 for i in range(n0_rows)]
    for i, y in enumerate(c0_y):
        circle = plt.Circle((x_positions[2], y), 0.06, color='#FF9800', ec='black', lw=1.5)
        ax.add_patch(circle)
        ax.text(x_positions[2], y, f'{i}', ha='center', va='center', fontsize=8, fontweight='bold', color='white')
    
    # Draw d₁ arrows (C₂ → C₁)
    for j in range(n2):
        for i in range(n1):
            if d1[i, j] != 0:
                color = '#1565C0' if d1[i, j] > 0 else '#C62828'
                style = '-' if d1[i, j] > 0 else '--'
                ax.annotate('', xy=(x_positions[1] + 0.07, c1_y[i]),
                           xytext=(x_positions[0] - 0.07, c2_y[j]),
                           arrowprops=dict(arrowstyle='->', color=color, lw=1.5, linestyle=style))
                mid_x = (x_positions[0] + x_positions[1]) / 2
                mid_y = (c2_y[j] + c1_y[i]) / 2
                ax.text(mid_x, mid_y + 0.04, str(d1[i, j]), fontsize=7, color=color,
                       ha='center', fontweight='bold')
    
    # Draw d₀ arrows (C₁ → C₀)
    for j in range(n1):
        for i in range(n0_rows):
            if d0[i, j] != 0:
                color = '#1565C0' if d0[i, j] > 0 else '#C62828'
                style = '-' if d0[i, j] > 0 else '--'
                ax.annotate('', xy=(x_positions[2] + 0.07, c0_y[i]),
                           xytext=(x_positions[1] - 0.07, c1_y[j]),
                           arrowprops=dict(arrowstyle='->', color=color, lw=1.5, linestyle=style))
                mid_x = (x_positions[1] + x_positions[2]) / 2
                mid_y = (c1_y[j] + c0_y[i]) / 2
                ax.text(mid_x, mid_y + 0.04, str(d0[i, j]), fontsize=7, color=color,
                       ha='center', fontweight='bold')
    
    # Labels
    ax.text(x_positions[0], max(c2_y) + 0.15, 'C₂', ha='center', fontsize=12, fontweight='bold', color='#2196F3')
    ax.text(x_positions[1], max(c1_y) + 0.15, 'C₁', ha='center', fontsize=12, fontweight='bold', color='#4CAF50')
    ax.text(x_positions[2], max(c0_y) + 0.15, 'C₀', ha='center', fontsize=12, fontweight='bold', color='#FF9800')
    
    ax.set_xlim(-0.15, 1.0)
    ax.set_ylim(0.1, max(max(c2_y), max(c1_y), max(c0_y)) + 0.25)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(title, fontsize=11, fontweight='bold', pad=10)
    
    if annotations:
        for ann in annotations:
            ax.text(ann['x'], ann['y'], ann['text'], fontsize=ann.get('fontsize', 9),
                   ha='center', color=ann.get('color', 'black'), 
                   fontweight=ann.get('fontweight', 'normal'),
                   bbox=dict(boxstyle='round,pad=0.3', facecolor=ann.get('bg', 'lightyellow'),
                            edgecolor='gray', alpha=0.8))

# Panel 1: Cancellation example
d1_cancel = np.array([[1], [-1]])
d0_cancel = np.array([[1, 1]])
draw_chain_complex(axes[0], d1_cancel, d0_cancel,
    'Cancellation: d₀[0,·]·d₁[·,0]\n= 1·1 + 1·(-1) = 0 ✓',
    annotations=[
        {'x': 0.4, 'y': 0.15, 'text': 'Two nonzero terms cancel', 
         'fontsize': 8, 'color': '#1B5E20', 'bg': '#C8E6C9'}
    ])

# Panel 2: Disjoint supports (diagonal-like)
d1_diag = np.array([[1, 0], [0, 1], [0, 0]])
d0_diag = np.array([[0, 0, 1]])
draw_chain_complex(axes[1], d1_diag, d0_diag,
    'Disjoint Supports (diagonal-like)\nim(d₁)={0,1}, supp(d₀)={2}',
    annotations=[
        {'x': 0.4, 'y': 0.12, 'text': 'No overlap → d²=0 automatic', 
         'fontsize': 8, 'color': '#0D47A1', 'bg': '#BBDEFB'}
    ])

# Panel 3: Forbidden lone survivor
d1_bad = np.array([[1], [0]])
d0_bad = np.array([[1, 0]])  # This violates d²=0 if d1[0,0]*d0[0,0] ≠ 0
draw_chain_complex(axes[2], d1_bad, d0_bad,
    'FORBIDDEN: Lone Survivor\nd₀[0,·]·d₁[·,0] = 1·1 = 1 ≠ 0 ✗',
    annotations=[
        {'x': 0.4, 'y': 0.15, 'text': 'Single nonzero term → d²≠0!', 
         'fontsize': 8, 'color': '#B71C1C', 'bg': '#FFCDD2'}
    ])

plt.suptitle('d² = 0 Constraint: Cancellation Patterns in Chain Complexes', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('d_sq_cancellation_patterns.png', dpi=150, bbox_inches='tight')
print("Saved: d_sq_cancellation_patterns.png")
