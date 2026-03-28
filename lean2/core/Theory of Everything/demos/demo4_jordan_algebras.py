#!/usr/bin/env python3
"""
Demo 4: Jordan Algebras and the Particle Spectrum
===================================================
Visualizes the exceptional Jordan algebra J₃(𝕆), its 27 dimensions,
and the decomposition into Standard Model particles.

Generates: fig7_jordan_algebra.png, fig8_particle_spectrum.png
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ─── Figure 7: The Exceptional Jordan Algebra J₃(𝕆) ───────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))

# Left: Structure of a 3×3 Hermitian octonionic matrix
ax1.set_xlim(-0.5, 6)
ax1.set_ylim(-1, 7)
ax1.axis('off')
ax1.set_title('The Exceptional Jordan Algebra J₃(𝕆)\n'
              '3×3 Hermitian Matrices over the Octonions',
              fontsize=14, fontweight='bold', fontfamily='serif')

# Draw the 3x3 matrix
matrix_x, matrix_y = 1.5, 2.5
cell = 1.2

# Big brackets
ax1.text(matrix_x - 0.3, matrix_y + 1.5, '⎛', fontsize=60,
         fontfamily='serif', color='#333333', va='center')
ax1.text(matrix_x - 0.3, matrix_y, '⎜', fontsize=60,
         fontfamily='serif', color='#333333', va='center')
ax1.text(matrix_x - 0.3, matrix_y - 1.5, '⎝', fontsize=60,
         fontfamily='serif', color='#333333', va='center')
ax1.text(matrix_x + 3*cell + 0.1, matrix_y + 1.5, '⎞', fontsize=60,
         fontfamily='serif', color='#333333', va='center')
ax1.text(matrix_x + 3*cell + 0.1, matrix_y, '⎟', fontsize=60,
         fontfamily='serif', color='#333333', va='center')
ax1.text(matrix_x + 3*cell + 0.1, matrix_y - 1.5, '⎠', fontsize=60,
         fontfamily='serif', color='#333333', va='center')

# Matrix entries
entries = [
    # Row 0
    [('ξ₁', '#E53935', 'ℝ'),   ('x₃', '#1E88E5', '𝕆'), ('x̄₂', '#43A047', '𝕆')],
    # Row 1  
    [('x̄₃', '#1E88E5', '𝕆'),   ('ξ₂', '#E53935', 'ℝ'),  ('x₁', '#FF8F00', '𝕆')],
    # Row 2
    [('x₂', '#43A047', '𝕆'),   ('x̄₁', '#FF8F00', '𝕆'),  ('ξ₃', '#E53935', 'ℝ')],
]

for i in range(3):
    for j in range(3):
        name, color, algebra = entries[i][j]
        x = matrix_x + j * cell + cell/2
        y = matrix_y + (1-i) * cell
        
        ax1.text(x, y, name, fontsize=16, fontweight='bold',
                ha='center', va='center', fontfamily='serif', color=color)
        ax1.text(x, y - 0.35, f'∈ {algebra}', fontsize=9,
                ha='center', va='center', fontfamily='serif',
                color='#999999')

# Dimension count
dim_text = (
    'Dimension count:\n'
    '• 3 diagonal entries ξᵢ ∈ ℝ     → 3\n'
    '• 3 off-diagonal xᵢ ∈ 𝕆         → 3 × 8 = 24\n'
    '• Total: 3 + 24 = 27\n\n'
    'Jordan product:\n'
    '  A ∘ B = ½(AB + BA)\n\n'
    'Key fact: J₃(𝕆) is NOT a\n'
    'matrix algebra — it is\n'
    'EXCEPTIONAL'
)
ax1.text(3, -0.3, dim_text, fontsize=10, fontfamily='serif',
         va='top', ha='center', color='#333333',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='#FFF8E1',
                  edgecolor='#FFD700'))

# Right: The automorphism group hierarchy
ax2.set_xlim(-1, 7)
ax2.set_ylim(-0.5, 7)
ax2.axis('off')
ax2.set_title('Symmetry Groups of J₃(𝕆)',
              fontsize=14, fontweight='bold', fontfamily='serif')

groups = [
    {'name': 'F₄', 'dim': 52, 'y': 5.5, 'color': '#FF6F00',
     'desc': 'Automorphism group\nAut(J₃(𝕆)) = F₄'},
    {'name': 'E₆', 'dim': 78, 'y': 3.5, 'color': '#E65100',
     'desc': 'Structure group\nStr(J₃(𝕆)) → E₆'},
    {'name': 'E₇', 'dim': 133, 'y': 1.5, 'color': '#BF360C',
     'desc': 'Quasi-conformal group\nJ₃(𝕆) × J₃(𝕆) → E₇'},
]

for g in groups:
    x = 3
    y = g['y']
    c = g['color']
    r = 0.6 + g['dim'] / 300
    
    circle = mpatches.FancyBboxPatch(
        (x - 1.5, y - 0.6), 3, 1.2,
        boxstyle="round,pad=0.1",
        facecolor=c + '22', edgecolor=c, linewidth=2
    )
    ax2.add_patch(circle)
    
    ax2.text(x, y + 0.15, f"{g['name']}  (dim {g['dim']})",
             fontsize=14, fontweight='bold', ha='center', va='center',
             fontfamily='serif', color=c)
    ax2.text(x, y - 0.25, g['desc'],
             fontsize=9, ha='center', va='center',
             fontfamily='serif', color='#666666')

# Arrows between groups
for i in range(len(groups) - 1):
    ax2.annotate('', xy=(3, groups[i+1]['y'] + 0.7),
                xytext=(3, groups[i]['y'] - 0.7),
                arrowprops=dict(arrowstyle='->', color='#999999', lw=1.5))
    ax2.text(3.8, (groups[i]['y'] + groups[i+1]['y'])/2, 'extends to',
             fontsize=9, fontfamily='serif', color='#999999',
             fontstyle='italic', va='center')

plt.tight_layout()
plt.savefig('Theory of Everything/demos/fig7_jordan_algebra.png', dpi=200,
            bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Saved fig7_jordan_algebra.png")


# ─── Figure 8: The 27 of E₆ as Particle Spectrum ──────────────────────────

fig, ax = plt.subplots(1, 1, figsize=(14, 10))
ax.set_xlim(-1, 13)
ax.set_ylim(-2, 9)
ax.axis('off')

ax.text(6, 8.5, 'The 27 of E₆: One Generation of Fermions',
        fontsize=18, fontweight='bold', ha='center', fontfamily='serif')
ax.text(6, 7.9, 'The exceptional Jordan algebra J₃(𝕆) encodes the particle spectrum',
        fontsize=11, ha='center', fontfamily='serif', fontstyle='italic',
        color='#555555')

# The 27 decomposes under SU(5) as 27 → 10 ⊕ 5̄ ⊕ 5 ⊕ 5̄ ⊕ 1 ⊕ 1
# Under SU(3)×SU(2)×U(1):
# Quarks
particles = {
    'Quarks (color triplets)': {
        'particles': [
            ('u_R', 'Up right', '#E53935', 0, 6.5),
            ('u_G', 'Up right', '#43A047', 1, 6.5),
            ('u_B', 'Up right', '#1E88E5', 2, 6.5),
            ('d_R', 'Down right', '#EF5350', 0, 5.5),
            ('d_G', 'Down right', '#66BB6A', 1, 5.5),
            ('d_B', 'Down right', '#42A5F5', 2, 5.5),
        ]
    },
    'Anti-quarks': {
        'particles': [
            ('ū_R', 'Up-bar', '#E53935', 4, 6.5),
            ('ū_G', 'Up-bar', '#43A047', 5, 6.5),
            ('ū_B', 'Up-bar', '#1E88E5', 6, 6.5),
            ('d̄_R', 'Down-bar', '#EF5350', 4, 5.5),
            ('d̄_G', 'Down-bar', '#66BB6A', 5, 5.5),
            ('d̄_B', 'Down-bar', '#42A5F5', 6, 5.5),
        ]
    },
    'Leptons': {
        'particles': [
            ('e⁻', 'Electron', '#9C27B0', 8.5, 6.5),
            ('νₑ', 'Neutrino', '#7B1FA2', 9.5, 6.5),
            ('e⁺', 'Positron', '#CE93D8', 8.5, 5.5),
            ('ν̄ₑ', 'Anti-neutrino', '#BA68C8', 9.5, 5.5),
        ]
    }
}

# Draw particles
all_particles = []
for group_name, group in particles.items():
    for name, desc, color, x, y in group['particles']:
        all_particles.append((name, desc, color, x, y))
        
        # Particle circle
        circle = plt.Circle((x + 0.5, y), 0.35, facecolor=color + '33',
                           edgecolor=color, linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x + 0.5, y, name, fontsize=9, fontweight='bold',
               ha='center', va='center', fontfamily='serif', color=color)

# Count
total = len(all_particles)

# Labels for groups
ax.text(1, 7.3, 'Quarks (×3 colors)', fontsize=11, fontweight='bold',
        ha='center', fontfamily='serif', color='#333333')
ax.text(5, 7.3, 'Anti-quarks (×3 colors)', fontsize=11, fontweight='bold',
        ha='center', fontfamily='serif', color='#333333')
ax.text(9, 7.3, 'Leptons', fontsize=11, fontweight='bold',
        ha='center', fontfamily='serif', color='#333333')

# Extra particles to make 27
ax.text(11.5, 6.5, 'ν_R', fontsize=9, fontweight='bold', ha='center',
        va='center', fontfamily='serif', color='#FF6F00')
circle = plt.Circle((11.5, 6.5), 0.35, facecolor='#FF6F00' + '33',
                   edgecolor='#FF6F00', linewidth=2, zorder=5)
ax.add_patch(circle)
ax.text(11.5, 7.3, 'Right ν', fontsize=11, fontweight='bold',
        ha='center', fontfamily='serif', color='#333333')

# Doublet structure boxes
rect1 = mpatches.FancyBboxPatch((-0.2, 5.0), 3.4, 2.2,
    boxstyle="round,pad=0.1", facecolor='none',
    edgecolor='#E53935', linewidth=1, linestyle='--')
ax.add_patch(rect1)

# The decomposition
decomp_text = (
    '27 of E₆ under SU(3) × SU(2) × U(1):\n\n'
    '27 = (3,2)₁/₆  ⊕  (3̄,1)₋₂/₃  ⊕  (3̄,1)₁/₃\n'
    '      ⊕  (1,2)₋₁/₂  ⊕  (1,1)₁  ⊕  (1,1)₀\n\n'
    '   = (u,d)_L  ⊕  ū_R  ⊕  d̄_R\n'
    '      ⊕  (ν,e)_L  ⊕  ē_R  ⊕  ν_R\n\n'
    '= One complete generation of fermions!'
)
ax.text(6, 2.5, decomp_text, fontsize=12, fontfamily='monospace',
        ha='center', va='center', color='#333333',
        bbox=dict(boxstyle='round,pad=0.8', facecolor='#E8F5E9',
                 edgecolor='#4CAF50', linewidth=2))

# Three generations
ax.text(6, 0, '× 3 generations (u/d, c/s, t/b) — possibly from SO(8) triality!',
        fontsize=12, fontweight='bold', ha='center', va='center',
        fontfamily='serif', color='#1565C0',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='#E3F2FD',
                 edgecolor='#1565C0', linewidth=1.5))

# Dimension count at bottom
ax.text(6, -1.2, 'Total particles per generation: 16 fermions + right-handed neutrino = 16+1\n'
        'In SU(5) GUT: 10 ⊕ 5̄ ⊕ 1   •   In SO(10) GUT: 16 (spinor representation)',
        fontsize=10, ha='center', va='center', fontfamily='serif',
        color='#666666')

plt.tight_layout()
plt.savefig('Theory of Everything/demos/fig8_particle_spectrum.png', dpi=200,
            bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Saved fig8_particle_spectrum.png")
