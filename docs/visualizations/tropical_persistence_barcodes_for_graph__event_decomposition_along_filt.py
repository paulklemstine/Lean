"""
Visualization: Event Decomposition Along a Filtration

Shows how the tropical kernel dimension evolves along a filtration,
decomposed into its cycle rank and visibility components, with
event annotations marking births and deaths.
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

# Interesting graph: two triangles sharing a vertex, plus a pendant
V = {0, 1, 2, 3, 4, 5, 6}
E = {
    (0, 1), (0, 2), (1, 2),     # Triangle 1
    (2, 3), (2, 4), (3, 4),     # Triangle 2
    (0, 5), (5, 6),             # Pendant chain
}
G = Graph(V, E)
q = 0

filt = [set(), {1}, {1,2}, {1,2,3}, {1,2,3,4}, {1,2,3,4,5}, {1,2,3,4,5,6}]

dims = compute_dims(G, q, filt)
cr_seq = [induced_cycle_rank(G, S) for S in filt]
vis_seq = [q_visible_component_count(G, q, S) for S in filt]
events = compute_tropical_barcode(G, q, filt)

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 9), gridspec_kw={'height_ratios': [2, 1]})

steps = np.arange(len(filt))

# Top: Stacked area chart showing decomposition
ax1.fill_between(steps, 0, cr_seq, alpha=0.4, color='steelblue', label='Cycle Rank β₁')
ax1.fill_between(steps, cr_seq, dims, alpha=0.4, color='forestgreen', label='q-Visible κ_q')
ax1.plot(steps, dims, 'ko-', linewidth=2.5, markersize=8, label='Total δ = β₁ + κ_q', zorder=5)
ax1.plot(steps, cr_seq, 'b--', linewidth=1.5, alpha=0.7)

# Annotate events
for k, e in enumerate(events):
    x = k + 0.5
    y = max(dims[k], dims[k+1]) + 0.15
    annotations = []
    if e.cycle_birth > 0:
        annotations.append(f'+{e.cycle_birth}🔄')
    if e.q_visible_birth > 0:
        annotations.append(f'+{e.q_visible_birth}👁')
    if e.invisible_merge_death > 0:
        annotations.append(f'-{e.invisible_merge_death}⊕')
    if annotations:
        ax1.annotate(' '.join(annotations), (x, y),
                    fontsize=11, ha='center', va='bottom',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

ax1.set_title('Tropical Kernel Dimension: Decomposition Along Filtration',
             fontsize=14, fontweight='bold')
ax1.set_xlabel('Filtration Step', fontsize=12)
ax1.set_ylabel('Dimension', fontsize=12)
ax1.legend(fontsize=11, loc='upper left')
ax1.set_xticks(steps)
ax1.set_xticklabels([f'S_{k}\n{str(sorted(S))[:20]}' for k, S in enumerate(filt)],
                    fontsize=8)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.3, max(dims) + 1.5)

# Bottom: Event bar chart
event_x = np.arange(len(events))
width = 0.25
bars_cycle = [e.cycle_birth for e in events]
bars_vis = [e.q_visible_birth for e in events]
bars_death = [-e.invisible_merge_death for e in events]
bars_delta = [e.delta for e in events]

ax2.bar(event_x - width, bars_cycle, width, color='steelblue', label='Cycle Birth', alpha=0.8)
ax2.bar(event_x, bars_vis, width, color='forestgreen', label='Visibility Birth', alpha=0.8)
ax2.bar(event_x + width, bars_death, width, color='indianred', label='Invisible Merge Death', alpha=0.8)
ax2.plot(event_x, bars_delta, 'k^-', markersize=10, linewidth=1.5, label='Net Δ', zorder=5)

ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.set_title('Event Decomposition per Step', fontsize=13, fontweight='bold')
ax2.set_xlabel('Transition', fontsize=12)
ax2.set_ylabel('Event Count', fontsize=12)
ax2.set_xticks(event_x)
ax2.set_xticklabels([f'{k}→{k+1}' for k in range(len(events))], fontsize=10)
ax2.legend(fontsize=9, ncol=4)
ax2.grid(True, alpha=0.3)

fig.suptitle(f'Tropical Persistence Barcode Analysis\n'
             f'Graph: two triangles + pendant, basepoint q={q}',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_event_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved: viz_event_decomposition.png")
