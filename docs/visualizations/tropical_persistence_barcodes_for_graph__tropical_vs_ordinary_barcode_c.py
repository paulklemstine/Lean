"""
Visualization: Tropical vs Ordinary Barcode Comparison

This script creates a side-by-side comparison of ordinary cycle persistence
(H₁ barcode) and the tropical persistence barcode, showing that the tropical
version captures strictly more information.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from algorithms import (
    Graph, tropical_kernel_dim, induced_cycle_rank,
    q_visible_component_count, compute_tropical_barcode,
    compute_dims
)

# Graph: square with two pendants
V = {0, 1, 2, 3, 4, 5}
E = {(0, 1), (1, 2), (2, 3), (0, 3), (0, 4), (2, 5)}
G = Graph(V, E)
q = 0

# Two filtrations with same H₁ but (potentially) different tropical barcodes
filt_A = [set(), {1}, {1, 4}, {1, 3, 4}, {1, 2, 3, 4}, {1, 2, 3, 4, 5}]
filt_B = [set(), {4}, {1, 4}, {1, 3, 4}, {1, 2, 3, 4}, {1, 2, 3, 4, 5}]

h1_A = [induced_cycle_rank(G, S) for S in filt_A]
h1_B = [induced_cycle_rank(G, S) for S in filt_B]
trop_A = compute_dims(G, q, filt_A)
trop_B = compute_dims(G, q, filt_B)
vis_A = [q_visible_component_count(G, q, S) for S in filt_A]
vis_B = [q_visible_component_count(G, q, S) for S in filt_B]

events_A = compute_tropical_barcode(G, q, filt_A)
events_B = compute_tropical_barcode(G, q, filt_B)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

steps = range(len(filt_A))

# Top left: H₁ comparison
axes[0, 0].plot(steps, h1_A, 'bo-', linewidth=2, markersize=8, label='Filtration A')
axes[0, 0].plot(steps, h1_B, 'rs--', linewidth=2, markersize=8, label='Filtration B')
axes[0, 0].set_title('Ordinary Cycle Rank β₁', fontsize=13, fontweight='bold')
axes[0, 0].set_xlabel('Filtration Step')
axes[0, 0].set_ylabel('β₁(G[S])')
axes[0, 0].legend()
axes[0, 0].set_ylim(-0.5, max(max(h1_A), max(h1_B)) + 1)
axes[0, 0].grid(True, alpha=0.3)

# Top right: Tropical dimension comparison
axes[0, 1].plot(steps, trop_A, 'bo-', linewidth=2, markersize=8, label='Filtration A')
axes[0, 1].plot(steps, trop_B, 'rs--', linewidth=2, markersize=8, label='Filtration B')
axes[0, 1].set_title('Tropical Kernel Dimension δ', fontsize=13, fontweight='bold')
axes[0, 1].set_xlabel('Filtration Step')
axes[0, 1].set_ylabel('δ(S) = β₁ + κ_q')
axes[0, 1].legend()
axes[0, 1].set_ylim(-0.5, max(max(trop_A), max(trop_B)) + 1)
axes[0, 1].grid(True, alpha=0.3)

# Bottom left: Visibility component
axes[1, 0].plot(steps, vis_A, 'g^-', linewidth=2, markersize=8, label='Filtration A')
axes[1, 0].plot(steps, vis_B, 'mv--', linewidth=2, markersize=8, label='Filtration B')
axes[1, 0].set_title('q-Visible Components κ_q', fontsize=13, fontweight='bold')
axes[1, 0].set_xlabel('Filtration Step')
axes[1, 0].set_ylabel('κ_q(S)')
axes[1, 0].legend()
axes[1, 0].set_ylim(-0.5, max(max(vis_A), max(vis_B)) + 1)
axes[1, 0].grid(True, alpha=0.3)

# Bottom right: Event barcode visualization
event_steps = np.arange(len(events_A))
width = 0.35
bars_A_cycle = [e.cycle_birth for e in events_A]
bars_A_vis = [e.q_visible_birth for e in events_A]
bars_A_death = [-e.invisible_merge_death for e in events_A]

axes[1, 1].bar(event_steps - width/2, bars_A_cycle, width, color='steelblue',
               label='Cycle births (A)', alpha=0.8)
axes[1, 1].bar(event_steps - width/2, bars_A_vis, width, bottom=bars_A_cycle,
               color='forestgreen', label='Vis. births (A)', alpha=0.8)
axes[1, 1].bar(event_steps - width/2, bars_A_death, width, color='indianred',
               label='Merges (A)', alpha=0.8)

bars_B_cycle = [e.cycle_birth for e in events_B]
bars_B_vis = [e.q_visible_birth for e in events_B]
bars_B_death = [-e.invisible_merge_death for e in events_B]

axes[1, 1].bar(event_steps + width/2, bars_B_cycle, width, color='steelblue',
               alpha=0.4, hatch='//')
axes[1, 1].bar(event_steps + width/2, bars_B_vis, width, bottom=bars_B_cycle,
               color='forestgreen', alpha=0.4, hatch='//', label='Vis. births (B)')
axes[1, 1].bar(event_steps + width/2, bars_B_death, width, color='indianred',
               alpha=0.4, hatch='//', label='Merges (B)')

axes[1, 1].set_title('Event Barcode Decomposition', fontsize=13, fontweight='bold')
axes[1, 1].set_xlabel('Transition')
axes[1, 1].set_ylabel('Event Count')
axes[1, 1].legend(fontsize=8)
axes[1, 1].grid(True, alpha=0.3)

fig.suptitle('Tropical Persistence vs Ordinary Cycle Persistence\n'
             f'Graph: square + 2 pendants, q={q}',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_barcode_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: viz_barcode_comparison.png")
