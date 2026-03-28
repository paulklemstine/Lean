"""
Demo 5: The Algebraic Unification Map

A comprehensive visualization showing how all physical theories emerge from
algebraic structures, and how they connect to each other.

This is the "grand unified diagram" of the Algebraic Theory of Physics.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle, Arc
import matplotlib.patheffects as path_effects

# ============================================================
# Figure 1: The Grand Unification Diagram
# ============================================================

fig, ax = plt.subplots(1, 1, figsize=(20, 24))
ax.set_xlim(0, 20)
ax.set_ylim(0, 24)
ax.axis('off')
ax.set_aspect('equal')

# Title
title = ax.text(10, 23.3, 'THE ALGEBRAIC THEORY OF PHYSICS', fontsize=24, 
               fontweight='bold', ha='center', va='center',
               bbox=dict(boxstyle='round,pad=0.4', facecolor='#1a1a2e', edgecolor='gold', linewidth=3),
               color='gold')
ax.text(10, 22.5, 'Physics is Algebra. Algebra is Physics.', fontsize=14, 
       ha='center', va='center', style='italic', color='#555')

# ============================================================
# Central Node: Spectral Triple
# ============================================================
central_box = FancyBboxPatch((6.5, 14), 7, 2.5, boxstyle="round,pad=0.3",
                              facecolor='#e74c3c', edgecolor='black', linewidth=3, alpha=0.9)
ax.add_patch(central_box)
ax.text(10, 15.6, 'SPECTRAL TRIPLE', fontsize=16, fontweight='bold', 
       ha='center', va='center', color='white')
ax.text(10, 15.0, '(A, H, D)', fontsize=20, fontweight='bold', 
       ha='center', va='center', color='white', fontfamily='serif')
ax.text(10, 14.4, 'Algebra • Hilbert Space • Dirac Operator', fontsize=10, 
       ha='center', va='center', color='#ffcccc')

# ============================================================
# Five Pillars
# ============================================================

pillars = [
    # (x, y, width, height, title, content, color)
    (1, 18.5, 4.5, 2.8, 'OBSERVABLE\nALGEBRA', 
     'C*-algebra A\n‖a*a‖ = ‖a‖²\nStates, GNS\nGelfand-Naimark', '#3498db'),
    
    (14.5, 18.5, 4.5, 2.8, 'SYMMETRY\nALGEBRA', 
     'Lie algebra 𝔤\n[X,Y] = XY−YX\nNoether\'s thm\nRep theory', '#2ecc71'),
    
    (0.5, 10, 4.5, 2.8, 'SPACETIME\nALGEBRA', 
     'Clifford Cl(V,Q)\n{eᵢ,eⱼ} = 2gᵢⱼ\nDirac equation\nSpinors', '#9b59b6'),
    
    (15, 10, 4.5, 2.8, 'GAUGE\nALGEBRA', 
     'Connections on\nG-bundles\nF = dA + A∧A\nYang-Mills', '#f39c12'),
    
    (7, 7.5, 6, 2.2, 'CATEGORICAL\nALGEBRA',
     'Monoidal categories • Functorial QFT\nCob_n → Vect • Composition of processes', '#e67e22'),
]

for x, y, w, h, title_text, content, color in pillars:
    box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.2",
                          facecolor=color, edgecolor='black', linewidth=2, alpha=0.85)
    ax.add_patch(box)
    ax.text(x + w/2, y + h - 0.5, title_text, fontsize=12, fontweight='bold',
           ha='center', va='center', color='white')
    ax.text(x + w/2, y + h/2 - 0.3, content, fontsize=8.5, ha='center', va='center',
           color='white', fontfamily='monospace', linespacing=1.3)

# ============================================================
# Physical Theories (emerging from the pillars)
# ============================================================

theories = [
    # (x, y, width, height, name, equation, color)
    (1, 4.2, 3.8, 1.8, 'CLASSICAL\nMECHANICS', 
     'A = C∞(T*M)\n{f,g} = Poisson', '#5dade2'),
    (5.5, 4.2, 3.8, 1.8, 'QUANTUM\nMECHANICS', 
     'A = B(H)\n[x̂,p̂] = iℏ', '#48c9b0'),
    (10.5, 4.2, 3.8, 1.8, 'GENERAL\nRELATIVITY', 
     'D² encodes gμν\nS = Tr f(D/Λ)', '#f1948a'),
    (15.2, 4.2, 3.8, 1.8, 'STANDARD\nMODEL', 
     'A_F = ℂ⊕ℍ⊕M₃(ℂ)\nG = U(1)×SU(2)×SU(3)', '#f7dc6f'),
]

for x, y, w, h, name, eq, color in theories:
    box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.15",
                          facecolor=color, edgecolor='black', linewidth=1.5, alpha=0.8)
    ax.add_patch(box)
    ax.text(x + w/2, y + h - 0.45, name, fontsize=10, fontweight='bold',
           ha='center', va='center', color='#1a1a2e')
    ax.text(x + w/2, y + 0.35, eq, fontsize=8, ha='center', va='center',
           color='#333', fontfamily='monospace')

# ============================================================
# Open Frontier
# ============================================================

frontier_box = FancyBboxPatch((3, 1), 14, 2.2, boxstyle="round,pad=0.3",
                               facecolor='#1a1a2e', edgecolor='gold', linewidth=2, alpha=0.9,
                               linestyle='--')
ax.add_patch(frontier_box)
ax.text(10, 2.5, 'THE FRONTIER: QUANTUM GRAVITY', fontsize=14, fontweight='bold',
       ha='center', va='center', color='gold')
ax.text(10, 1.6, 'A = ??? (quantum spacetime algebra)  •  D = ??? (dynamical Dirac operator)  •  No background geometry',
       fontsize=9, ha='center', va='center', color='#aaa', fontfamily='monospace')

# ============================================================
# Connecting arrows
# ============================================================

arrow_style = dict(arrowstyle='->', lw=2, color='#555')

# Pillars to central spectral triple
connections = [
    ((3.25, 18.5), (7.5, 16.5)),   # Observable → ST
    ((16.75, 18.5), (12.5, 16.5)), # Symmetry → ST
    ((4.5, 11.4), (6.5, 14.5)),    # Spacetime → ST
    ((15, 11.4), (13.5, 14.5)),    # Gauge → ST
    ((10, 9.7), (10, 14)),          # Category → ST
]

for start, end in connections:
    arrow = FancyArrowPatch(start, end, connectionstyle="arc3,rad=0.05",
                            arrowstyle='->', mutation_scale=20, lw=2, color='#888')
    ax.add_patch(arrow)

# Spectral triple to physical theories
theory_connections = [
    ((7.5, 14), (2.9, 6)),     # ST → Classical
    ((8.5, 14), (7.4, 6)),     # ST → QM
    ((11.5, 14), (12.4, 6)),   # ST → GR
    ((12.5, 14), (17.1, 6)),   # ST → SM
]

for start, end in theory_connections:
    arrow = FancyArrowPatch(start, end, connectionstyle="arc3,rad=0.1",
                            arrowstyle='->', mutation_scale=20, lw=2.5, color='#e74c3c',
                            linestyle='--')
    ax.add_patch(arrow)

# Theories to frontier
for x_center in [2.9, 7.4, 12.4, 17.1]:
    arrow = FancyArrowPatch((x_center, 4.2), (x_center, 3.2),
                            arrowstyle='->', mutation_scale=15, lw=1.5, color='gold',
                            linestyle=':')
    ax.add_patch(arrow)

# ============================================================
# Key equations sidebar
# ============================================================
eq_box = FancyBboxPatch((0.2, 0.2), 5, 3.5, boxstyle="round,pad=0.2",
                         facecolor='white', edgecolor='#ccc', linewidth=1, alpha=0.0)

# ============================================================
# Inter-pillar connections
# ============================================================
# Observable ↔ Symmetry (automorphisms)
arrow = FancyArrowPatch((5.5, 20), (14.5, 20), connectionstyle="arc3,rad=0.15",
                        arrowstyle='<->', mutation_scale=15, lw=1.5, color='#27ae60')
ax.add_patch(arrow)
ax.text(10, 21, 'G acts on A by\n*-automorphisms', fontsize=8, ha='center', va='center',
       color='#27ae60', fontweight='bold')

# Spacetime ↔ Gauge (fiber bundles)
arrow = FancyArrowPatch((5, 11), (15, 11), connectionstyle="arc3,rad=-0.15",
                        arrowstyle='<->', mutation_scale=15, lw=1.5, color='#8e44ad')
ax.add_patch(arrow)
ax.text(10, 10.2, 'Gauge fields = Connections\non spacetime bundles', fontsize=8, 
       ha='center', va='center', color='#8e44ad', fontweight='bold')

plt.savefig('/workspace/request-project/figures/demo5_unification.png', dpi=150, bbox_inches='tight')
plt.close()
print("✅ Figure saved: figures/demo5_unification.png")


# ============================================================
# Figure 2: Timeline of the Algebraic Theory
# ============================================================

fig2, ax2 = plt.subplots(1, 1, figsize=(20, 8))

events = [
    (1843, 'Hamilton\nQuaternions ℍ', '#e74c3c', 'above'),
    (1878, 'Clifford\nCl(V,Q)', '#9b59b6', 'below'),
    (1918, 'Noether\nSymmetry→\nConservation', '#2ecc71', 'above'),
    (1925, 'Heisenberg\nMatrix QM', '#3498db', 'below'),
    (1928, 'Dirac\niγμ∂μψ=mψ', '#e74c3c', 'above'),
    (1932, 'von Neumann\nOperator\nAlgebras', '#3498db', 'below'),
    (1943, 'Gelfand-\nNaimark\nC*-algebras', '#f39c12', 'above'),
    (1954, 'Yang-Mills\nGauge\nTheory', '#f39c12', 'below'),
    (1961, 'Gell-Mann\nEightfold\nWay', '#2ecc71', 'above'),
    (1964, 'Haag-Kastler\nAlgebraic\nQFT', '#3498db', 'below'),
    (1988, 'Witten\nTQFT as\nFunctor', '#9b59b6', 'above'),
    (1996, 'Connes\nSpectral\nAction', '#e74c3c', 'below'),
    (2025, 'Algebraic\nTheory of\nPhysics?', '#1a1a2e', 'above'),
]

ax2.set_xlim(1835, 2035)
ax2.set_ylim(-3, 3.5)
ax2.axis('off')

# Timeline
ax2.axhline(y=0, xmin=0.02, xmax=0.98, color='#333', linewidth=3)

# Title
ax2.text(1935, 3.2, 'Timeline: The Algebraic Theory of Physics', 
        fontsize=16, fontweight='bold', ha='center')

for year, label, color, pos in events:
    # Marker on timeline
    ax2.plot(year, 0, 'o', color=color, markersize=10, zorder=5)
    
    # Vertical line
    y_text = 1.8 if pos == 'above' else -1.8
    ax2.plot([year, year], [0, y_text * 0.6], '-', color=color, linewidth=1.5)
    
    # Label
    ax2.text(year, y_text, label, fontsize=8, ha='center', va='center',
            fontweight='bold', color=color,
            bbox=dict(boxstyle='round,pad=0.2', facecolor='white', edgecolor=color, 
                     linewidth=1.5, alpha=0.9))
    
    # Year
    y_year = 0.4 if pos == 'above' else -0.4
    ax2.text(year, y_year, str(year), fontsize=7, ha='center', va='center', color='#666')

plt.savefig('/workspace/request-project/figures/demo5_timeline.png', dpi=150, bbox_inches='tight')
plt.close()
print("✅ Figure saved: figures/demo5_timeline.png")
