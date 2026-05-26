#!/usr/bin/env python3
"""
Visualize the building expander mixing lemma for the C₂-building
of Sp₄(𝔽_q). Shows how the mixing constant √(1-gap) decays as
q grows, and how the deviation bound tightens for larger buildings.

This illustrates the cross-domain connection: building Hecke spectra
control combinatorial incidence statistics.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def building_hecke_gap(q):
    return 1.0 - 2.0 / np.sqrt(q)

def building_vertices(q):
    n1 = q**3 + q**2 + q + 1
    n2 = (q**2 + 1) * (q + 1)
    return n1, n2

def building_edges(q):
    _, n2 = building_vertices(q)
    return n2 * (q + 1)

def mixing_constant(q):
    gap = building_hecke_gap(q)
    return np.sqrt(max(0, 1 - gap))

def expected_incidence(q, frac_a, frac_b):
    n1, n2 = building_vertices(q)
    E = building_edges(q)
    a = int(frac_a * n1)
    b = int(frac_b * n2)
    return E * (a / n1) * (b / n2), a, b

def mixing_bound(q, a, b):
    gap = building_hecke_gap(q)
    E = building_edges(q)
    return np.sqrt(max(0, 1 - gap)) * np.sqrt(E) * np.sqrt(a * b)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

qs = np.arange(5, 200)

# Plot 1: Mixing constant decay
ax = axes[0, 0]
mcs = [mixing_constant(q) for q in qs]
ax.plot(qs, mcs, 'g-', linewidth=2)
ax.fill_between(qs, 0, mcs, alpha=0.15, color='green')
ax.set_xlabel('q', fontsize=11)
ax.set_ylabel('√(1 − gap)', fontsize=11)
ax.set_title('Mixing Constant Decay', fontsize=12)
ax.grid(True, alpha=0.2)
ax.annotate(f'q=5: {mixing_constant(5):.3f}', xy=(5, mixing_constant(5)),
            xytext=(30, mixing_constant(5) + 0.05),
            arrowprops=dict(arrowstyle='->', color='gray'),
            fontsize=9)
ax.annotate(f'q=100: {mixing_constant(100):.3f}', xy=(100, mixing_constant(100)),
            xytext=(120, mixing_constant(100) + 0.1),
            arrowprops=dict(arrowstyle='->', color='gray'),
            fontsize=9)

# Plot 2: Relative error bound vs q
ax = axes[0, 1]
frac = 0.1
rel_errors = []
for q in qs:
    exp, a, b = expected_incidence(q, frac, frac)
    mb = mixing_bound(q, a, b)
    rel_errors.append(mb / exp if exp > 0 else float('nan'))
ax.plot(qs, rel_errors, 'b-', linewidth=2)
ax.set_xlabel('q', fontsize=11)
ax.set_ylabel('Relative error bound', fontsize=11)
ax.set_title(f'Mixing Error for {int(frac*100)}% Subsets', fontsize=12)
ax.grid(True, alpha=0.2)
ax.set_yscale('log')

# Plot 3: Building size growth
ax = axes[1, 0]
n1s = [building_vertices(q)[0] for q in qs]
n2s = [building_vertices(q)[1] for q in qs]
edges = [building_edges(q) for q in qs]
ax.semilogy(qs, n1s, 'r-', linewidth=2, label='Type-1 vertices')
ax.semilogy(qs, n2s, 'b-', linewidth=2, label='Type-2 vertices')
ax.semilogy(qs, edges, 'g--', linewidth=2, label='Edges')
ax.set_xlabel('q', fontsize=11)
ax.set_ylabel('Count (log scale)', fontsize=11)
ax.set_title('Building Size Growth', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.2)

# Plot 4: Heatmap of mixing quality
ax = axes[1, 1]
qs_heat = [5, 7, 11, 17, 25, 49, 97]
fracs = [0.01, 0.05, 0.1, 0.2, 0.3, 0.5]
quality_matrix = np.zeros((len(fracs), len(qs_heat)))
for i, f in enumerate(fracs):
    for j, q in enumerate(qs_heat):
        exp, a, b = expected_incidence(q, f, f)
        mb = mixing_bound(q, a, b)
        quality_matrix[i, j] = mb / exp if exp > 0 else float('nan')

im = ax.imshow(quality_matrix, cmap='RdYlGn_r', aspect='auto',
               vmin=0, vmax=2)
ax.set_xticks(range(len(qs_heat)))
ax.set_xticklabels([str(q) for q in qs_heat])
ax.set_yticks(range(len(fracs)))
ax.set_yticklabels([f'{int(f*100)}%' for f in fracs])
ax.set_xlabel('q', fontsize=11)
ax.set_ylabel('Subset fraction', fontsize=11)
ax.set_title('Relative Mixing Error (green=good)', fontsize=12)
plt.colorbar(im, ax=ax, label='Relative error bound')

plt.suptitle('Building Expander Mixing for C₂-Building of Sp₄(𝔽_q)',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('visualize_building_mixing.png', dpi=150, bbox_inches='tight')
print("Saved: visualize_building_mixing.png")
