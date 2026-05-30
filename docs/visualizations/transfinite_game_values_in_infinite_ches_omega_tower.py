"""
Visualization: The ω-Tower and Ordinal Arithmetic

Illustrates the relationships between ordinal operations and how they
build up the transfinite hierarchy of game values.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# === Left panel: Ordinal addition and multiplication ===
ax1 = axes[0]
ax1.set_xlim(0, 10)
ax1.set_ylim(0, 6)
ax1.axis('off')
ax1.set_title('Ordinal Arithmetic: Building Blocks', fontsize=14, fontweight='bold')

# Draw number lines showing ordinal structure
y_levels = [5, 3.5, 2, 0.5]
labels = ['Finite: 0, 1, 2, ..., n', 
          'ω = sup{0, 1, 2, ...}',
          'ω·2 = ω + ω',
          'ω² = ω·ω']

for i, (y, label) in enumerate(zip(y_levels, labels)):
    # Draw base line
    ax1.plot([0.5, 9.5], [y, y], 'k-', linewidth=1.5)
    ax1.text(5, y + 0.4, label, ha='center', va='bottom', fontsize=11, 
             fontweight='bold', color=['#2196F3', '#4CAF50', '#FF9800', '#F44336'][i])
    
    if i == 0:  # Finite
        for j in range(8):
            x = 0.5 + j * 1.1
            ax1.plot(x, y, 'o', color='#2196F3', markersize=6)
            ax1.text(x, y - 0.25, str(j), ha='center', fontsize=8)
        ax1.text(9.3, y - 0.25, '...', ha='center', fontsize=10)
    
    elif i == 1:  # ω
        for j in range(8):
            x = 0.5 + j * 1.1
            ax1.plot(x, y, 'o', color='#4CAF50', markersize=5)
        ax1.plot(9.5, y, '*', color='#4CAF50', markersize=12)
        ax1.text(9.5, y - 0.25, 'ω', ha='center', fontsize=9, fontweight='bold')
    
    elif i == 2:  # ω·2
        # First copy of ω
        for j in range(4):
            x = 0.5 + j * 0.8
            ax1.plot(x, y, 'o', color='#FF9800', markersize=4)
        ax1.plot(3.7, y, 's', color='#FF9800', markersize=8)
        ax1.text(3.7, y - 0.25, 'ω', ha='center', fontsize=8)
        # Second copy of ω
        for j in range(4):
            x = 5 + j * 0.8
            ax1.plot(x, y, 'o', color='#FF9800', markersize=4)
        ax1.plot(8.2, y, 's', color='#FF9800', markersize=8)
        ax1.text(8.2, y - 0.25, 'ω·2', ha='center', fontsize=8)
        # Bracket
        ax1.annotate('', xy=(0.5, y - 0.12), xytext=(3.5, y - 0.12),
                    arrowprops=dict(arrowstyle='<->', color='#FF9800', lw=1))
        ax1.annotate('', xy=(5, y - 0.12), xytext=(8, y - 0.12),
                    arrowprops=dict(arrowstyle='<->', color='#FF9800', lw=1))
    
    elif i == 3:  # ω²
        # Show ω copies of ω
        for k in range(4):
            x_start = 0.5 + k * 2.2
            for j in range(3):
                x = x_start + j * 0.5
                ax1.plot(x, y, 'o', color='#F44336', markersize=3)
            ax1.plot(x_start + 1.5, y, '|', color='#F44336', markersize=8)
        ax1.text(9.3, y - 0.25, '...', ha='center', fontsize=10, color='#F44336')
        ax1.text(5, y - 0.3, '(ω copies of ω)', ha='center', fontsize=8, 
                 style='italic', color='#F44336')

# === Right panel: Ordinal exponentiation tower ===
ax2 = axes[1]
ax2.set_xlim(0, 10)
ax2.set_ylim(-0.5, 8)
ax2.axis('off')
ax2.set_title('The ω-Power Tower', fontsize=14, fontweight='bold')

# Draw the tower
tower_data = [
    (0, '1 = ω⁰', '#9E9E9E', 'One move to win'),
    (1, 'ω = ω¹', '#2196F3', 'Infinite moves (e.g., rook chase)'),
    (2, 'ω² = ω·ω', '#4CAF50', '∞ rounds of ∞ moves each'),
    (3, 'ω³', '#FF9800', '∞ rounds of ω² games'),
    (4, 'ω⁴', '#F44336', '∞ rounds of ω³ games'),
    (5, '⋮', '#9E9E9E', ''),
    (6, 'ω^n', '#9C27B0', 'n-deep nesting of ∞'),
    (7, 'ω^ω = sup', '#D32F2F', 'Infinite nesting depth'),
]

for i, (level, name, color, desc) in enumerate(tower_data):
    y = i * 0.95 + 0.5
    
    if name == '⋮':
        ax2.text(3, y, '⋮', fontsize=20, ha='center', va='center', color='gray')
        continue
    
    # Draw box
    width = 5.5 - i * 0.3
    x_start = 3 - width / 2
    
    rect = plt.Rectangle((x_start, y - 0.3), width, 0.6,
                         facecolor=color, alpha=0.2, edgecolor=color, 
                         linewidth=2, zorder=3)
    ax2.add_patch(rect)
    
    ax2.text(3, y, name, ha='center', va='center', fontsize=12,
             fontweight='bold', color=color, zorder=4)
    
    if desc:
        ax2.text(3 + width/2 + 0.3, y, desc, ha='left', va='center', 
                 fontsize=8, color='#666', style='italic')

# Arrow indicating growth
ax2.annotate('', xy=(8.5, 7.5), xytext=(8.5, 0.5),
            arrowprops=dict(arrowstyle='->', color='red', lw=2.5))
ax2.text(8.5, 4, 'Complexity\ngrowth', ha='center', va='center',
         fontsize=10, color='red', fontweight='bold', rotation=90)

plt.tight_layout()
plt.savefig('omega_tower.png', dpi=150, bbox_inches='tight')
print("Saved omega_tower.png")
